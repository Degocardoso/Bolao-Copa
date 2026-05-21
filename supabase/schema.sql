-- ============================================================
--  BOLÃO DA COPA DO MUNDO — Estrutura do Banco de Dados
--  Cole este arquivo inteiro no Supabase: SQL Editor > New query > Run
--  Regra: acertou o PLACAR EXATO = 3 pontos. Caso contrário = 0.
-- ============================================================

-- ---------- LIMPEZA (caso rode novamente) ----------
drop view if exists ranking cascade;
drop table if exists palpites cascade;
drop table if exists jogos cascade;
drop table if exists times cascade;
drop table if exists perfis cascade;

-- ============================================================
--  TABELA: perfis
-- ============================================================
create table perfis (
  id          uuid primary key references auth.users(id) on delete cascade,
  nome        text not null,
  email       text not null,
  avatar_url  text,
  criado_em   timestamptz default now()
);

-- ============================================================
--  TABELA: times
-- ============================================================
create table times (
  id        bigint generated always as identity primary key,
  nome      text not null,
  bandeira  text,
  grupo     text
);

-- ============================================================
--  TABELA: jogos
-- ============================================================
create table jogos (
  id            bigint generated always as identity primary key,
  fase          text not null default 'grupos',
  rodada        text,
  time_casa     bigint references times(id),
  time_fora     bigint references times(id),
  inicio        timestamptz not null,
  gols_casa     smallint check (gols_casa >= 0),
  gols_fora     smallint check (gols_fora >= 0),
  criado_em     timestamptz default now()
);

-- ============================================================
--  TABELA: palpites
-- ============================================================
create table palpites (
  id            bigint generated always as identity primary key,
  usuario_id    uuid not null references perfis(id) on delete cascade,
  jogo_id       bigint not null references jogos(id) on delete cascade,
  gols_casa     smallint not null check (gols_casa >= 0),
  gols_fora     smallint not null check (gols_fora >= 0),
  atualizado_em timestamptz default now(),
  unique (usuario_id, jogo_id)
);

-- ============================================================
--  ÍNDICES
-- ============================================================
create index idx_palpites_usuario on palpites(usuario_id);
create index idx_palpites_jogo on palpites(jogo_id);
create index idx_jogos_inicio on jogos(inicio);

-- ============================================================
--  GATILHO: cria o perfil automaticamente no primeiro login
-- ============================================================
create or replace function public.criar_perfil()
returns trigger as $$
begin
  insert into public.perfis (id, nome, email, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists ao_criar_usuario on auth.users;
create trigger ao_criar_usuario
  after insert on auth.users
  for each row execute function public.criar_perfil();

-- ============================================================
--  VIEW: ranking  (3 pontos por placar exato cravado)
-- ============================================================
create or replace view ranking as
select
  p.id            as usuario_id,
  p.nome,
  p.avatar_url,
  coalesce(sum(
    case
      when j.gols_casa is not null
       and j.gols_fora is not null
       and pl.gols_casa = j.gols_casa
       and pl.gols_fora = j.gols_fora
      then 3 else 0
    end
  ), 0) as pontos,
  count(pl.id) filter (
    where j.gols_casa is not null and j.gols_fora is not null
  ) as jogos_avaliados,
  count(pl.id) filter (
    where j.gols_casa is not null and j.gols_fora is not null
      and pl.gols_casa = j.gols_casa and pl.gols_fora = j.gols_fora
  ) as placares_cravados
from perfis p
left join palpites pl on pl.usuario_id = p.id
left join jogos j on j.id = pl.jogo_id
group by p.id, p.nome, p.avatar_url;

-- ============================================================
--  SEGURANÇA (Row Level Security)
-- ============================================================
alter table perfis   enable row level security;
alter table times    enable row level security;
alter table jogos    enable row level security;
alter table palpites enable row level security;

create policy "perfis: leitura para logados"
  on perfis for select to authenticated using (true);
create policy "perfis: edita o proprio"
  on perfis for update to authenticated using (auth.uid() = id);

create policy "times: leitura para logados"
  on times for select to authenticated using (true);

create policy "jogos: leitura para logados"
  on jogos for select to authenticated using (true);

create policy "palpites: leitura dos proprios"
  on palpites for select to authenticated
  using (auth.uid() = usuario_id);

create policy "palpites: inserir antes do jogo"
  on palpites for insert to authenticated
  with check (
    auth.uid() = usuario_id
    and (select inicio from jogos where jogos.id = jogo_id) > now()
  );

create policy "palpites: editar antes do jogo"
  on palpites for update to authenticated
  using (
    auth.uid() = usuario_id
    and (select inicio from jogos where jogos.id = jogo_id) > now()
  );

-- ============================================================
--  FIM. 🎉
-- ============================================================
