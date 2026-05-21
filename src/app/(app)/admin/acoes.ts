'use server';

import { revalidatePath } from 'next/cache';
import { criarClienteServidor } from '@/lib/supabase-server';
import { criarClienteAdmin, ehAdmin } from '@/lib/supabase-admin';

// Garante que quem chamou é admin de verdade (checa a sessão no servidor)
async function exigirAdmin() {
  const supabase = criarClienteServidor();
  const { data } = await supabase.auth.getUser();
  if (!ehAdmin(data?.user?.email)) {
    throw new Error('Acesso negado: apenas administradores.');
  }
}

export async function criarTime(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const nome = String(formData.get('nome') || '').trim();
  const bandeira = String(formData.get('bandeira') || '').trim() || null;
  const grupo = String(formData.get('grupo') || '').trim() || null;
  if (!nome) return;
  await admin.from('times').insert({ nome, bandeira, grupo });
  revalidatePath('/admin');
  revalidatePath('/jogos');
}

export async function apagarTime(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const id = Number(formData.get('id'));
  await admin.from('times').delete().eq('id', id);
  revalidatePath('/admin');
}

export async function criarJogo(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const fase = String(formData.get('fase') || 'grupos');
  const rodada = String(formData.get('rodada') || '').trim() || null;
  const time_casa = Number(formData.get('time_casa')) || null;
  const time_fora = Number(formData.get('time_fora')) || null;
  const inicioLocal = String(formData.get('inicio') || '');
  if (!inicioLocal) return;
  // datetime-local vem sem fuso; tratamos como horario local do Brasil
  const inicio = new Date(inicioLocal).toISOString();
  await admin.from('jogos').insert({ fase, rodada, time_casa, time_fora, inicio });
  revalidatePath('/admin');
  revalidatePath('/jogos');
}

export async function apagarJogo(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const id = Number(formData.get('id'));
  await admin.from('jogos').delete().eq('id', id);
  revalidatePath('/admin');
  revalidatePath('/jogos');
}

export async function lancarPlacar(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const id = Number(formData.get('id'));
  const gols_casa = Number(formData.get('gols_casa'));
  const gols_fora = Number(formData.get('gols_fora'));
  await admin.from('jogos').update({ gols_casa, gols_fora }).eq('id', id);
  revalidatePath('/admin');
  revalidatePath('/jogos');
  revalidatePath('/ranking');
  revalidatePath('/meus-palpites');
}

export async function limparPlacar(formData: FormData) {
  await exigirAdmin();
  const admin = criarClienteAdmin();
  const id = Number(formData.get('id'));
  await admin.from('jogos').update({ gols_casa: null, gols_fora: null }).eq('id', id);
  revalidatePath('/admin');
  revalidatePath('/ranking');
}
