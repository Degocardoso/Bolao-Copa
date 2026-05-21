import { redirect } from 'next/navigation';
import { criarClienteServidor } from '@/lib/supabase-server';
import { ehAdmin } from '@/lib/supabase-admin';
import Cabecalho from '@/components/Cabecalho';

export default async function LayoutApp({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = criarClienteServidor();
  const { data } = await supabase.auth.getUser();
  if (!data?.user) redirect('/');

  const nome =
    (data.user.user_metadata?.full_name as string) ||
    (data.user.user_metadata?.name as string) ||
    data.user.email?.split('@')[0] ||
    'Participante';

  return (
    <>
      <Cabecalho nome={nome} admin={ehAdmin(data.user.email)} />
      <div style={{ paddingBottom: 60 }}>{children}</div>
    </>
  );
}
