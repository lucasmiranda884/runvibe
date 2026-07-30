"use client";

import { FormEvent, useEffect, useMemo, useRef, useState } from "react";

type View = "inicio" | "gravar" | "treinador" | "pessoas" | "clubes" | "provas" | "perfil";
type Point = { latitude: number; longitude: number; elevation: number; speedMs: number; heartRate: number; timestamp: string };
type Draft = {
  localId: string; startTime: string; elapsed: number; moving: number;
  distance: number; points: Point[]; sportType: string; pending: boolean;
};
type FeedItem = {
  id?: string; userId?: string; userName?: string; title?: string; description?: string; sportType?: string;
  totalDistanceMeters?: number; elapsedTimeSeconds?: number;
  movingTimeSeconds?: number; averagePaceSecondsPerKm?: number; elevationGainMeters?: number; createdAt?: string;
  splits?: ActivitySplit[];
};
type ActivitySplit = { kilometer:number; distanceMeters:number; durationSeconds:number; paceSecondsPerKm:number };
type ActivityComment = {
  id: string; userId: string; userName: string; content: string; createdAt: string;
};

const API = "/api/runvibe";
const sports = [
  ["RUNNING", "Corrida"], ["CYCLING", "Ciclismo"],
  ["WALKING", "Caminhada"], ["HIKING", "Trilha"],
];

function haversine(a: Point, b: Point) {
  const r = 6371000, rad = Math.PI / 180;
  const dLat = (b.latitude - a.latitude) * rad;
  const dLon = (b.longitude - a.longitude) * rad;
  const x = Math.sin(dLat / 2) ** 2 +
    Math.cos(a.latitude * rad) * Math.cos(b.latitude * rad) * Math.sin(dLon / 2) ** 2;
  return 2 * r * Math.asin(Math.sqrt(x));
}
function clock(value: number) {
  const h = Math.floor(value / 3600), m = Math.floor(value % 3600 / 60), s = value % 60;
  return h ? `${h}:${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}` : `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}
function pace(seconds: number) { return seconds ? `${clock(seconds)}/km` : "--:--"; }
function token() { return typeof window === "undefined" ? null : localStorage.getItem("runvibe.token"); }
async function api(path: string, init: RequestInit = {}) {
  const headers = new Headers(init.headers);
  headers.set("Content-Type", "application/json");
  const jwt = token();
  if (jwt) headers.set("Authorization", `Bearer ${jwt}`);
  const response = await fetch(`${API}/${path}`, { ...init, headers });
  if (!response.ok) {
    const body = await response.json().catch(() => ({}));
    throw new Error(body.message || (response.status === 401 ? "E-mail ou senha incorretos." : "Não foi possível concluir agora."));
  }
  return response.json();
}

export default function Home() {
  const [authenticated, setAuthenticated] = useState(false);
  const [view, setView] = useState<View>("inicio");
  const [dark, setDark] = useState(false);
  const [toast, setToast] = useState("");

  useEffect(() => {
    setAuthenticated(Boolean(token()));
    setDark(localStorage.getItem("runvibe.theme") === "dark");
    if ("serviceWorker" in navigator) navigator.serviceWorker.register("/sw.js").catch(() => undefined);
  }, []);

  useEffect(() => {
    document.documentElement.dataset.theme = dark ? "dark" : "light";
    localStorage.setItem("runvibe.theme", dark ? "dark" : "light");
  }, [dark]);

  const notify = (message: string) => {
    setToast(message);
    window.setTimeout(() => setToast(""), 3500);
  };

  if (!authenticated) return <Login onSuccess={() => setAuthenticated(true)} />;

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <button className="brand" onClick={() => setView("inicio")} aria-label="Página inicial">
          <span className="brand-mark">R</span><strong>RUNVIBE</strong>
        </button>
        <nav>
          <Nav active={view === "inicio"} icon="⌂" label="Início" onClick={() => setView("inicio")} />
          <Nav active={view === "gravar"} icon="●" label="Gravar" onClick={() => setView("gravar")} />
          <Nav active={view === "treinador"} icon="✦" label="Treinador" onClick={() => setView("treinador")} />
          <Nav active={view === "pessoas"} icon="◉" label="Pessoas" onClick={() => setView("pessoas")} />
          <Nav active={view === "clubes"} icon="◎" label="Clubes" onClick={() => setView("clubes")} />
          <Nav active={view === "provas"} icon="◇" label="Provas" onClick={() => setView("provas")} />
          <Nav active={view === "perfil"} icon="○" label="Perfil" onClick={() => setView("perfil")} />
        </nav>
        <div className="sidebar-foot">
          <button className="theme-button" onClick={() => setDark(!dark)}>{dark ? "☀ Tema claro" : "☾ Tema escuro"}</button>
          <span className="online-dot" /> API RunVibe
        </div>
      </aside>
      <main>
        <header className="topbar">
          <div>
            <p className="eyebrow">TREINE. EVOLUA. COMPARTILHE.</p>
            <h1>{({ inicio: "Seu ritmo, sua comunidade", gravar: "Gravar atividade", treinador: "Treinador RunVibe", pessoas: "Encontre pessoas", clubes: "Clubes", provas: "Calendário de provas", perfil: "Seu perfil" } as Record<View,string>)[view]}</h1>
          </div>
          <div className="top-actions">
            <button className="icon-button" onClick={() => notify("Nenhuma nova notificação.")} aria-label="Notificações">♢</button>
            <button className="avatar" onClick={() => setView("perfil")}>LM</button>
          </div>
        </header>
        {view === "inicio" && <Dashboard onRecord={() => setView("gravar")} onCoach={() => setView("treinador")} notify={notify} />}
        {view === "gravar" && <Recorder notify={notify} />}
        {view === "treinador" && <Coach notify={notify} />}
        {view === "pessoas" && <People notify={notify} />}
        {view === "clubes" && <Clubs notify={notify} />}
        {view === "provas" && <Races notify={notify} />}
        {view === "perfil" && <Profile onLogout={() => { localStorage.removeItem("runvibe.token"); setAuthenticated(false); }} />}
      </main>
      <div className="mobile-nav">
        <Nav active={view === "inicio"} icon="⌂" label="Início" onClick={() => setView("inicio")} />
        <Nav active={view === "treinador"} icon="✦" label="Treinos" onClick={() => setView("treinador")} />
        <button className="record-tab" onClick={() => setView("gravar")}>●</button>
        <Nav active={view === "clubes"} icon="◎" label="Clubes" onClick={() => setView("clubes")} />
        <Nav active={view === "pessoas"} icon="◉" label="Pessoas" onClick={() => setView("pessoas")} />
      </div>
      {toast && <div className="toast">{toast}</div>}
    </div>
  );
}

function Nav({ active, icon, label, onClick }: { active: boolean; icon: string; label: string; onClick: () => void }) {
  return <button className={`nav-item ${active ? "active" : ""}`} onClick={onClick}><span>{icon}</span>{label}</button>;
}

function Login({ onSuccess }: { onSuccess: () => void }) {
  const [register, setRegister] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault(); setLoading(true); setError("");
    const data = new FormData(event.currentTarget);
    try {
      const body = register
        ? { name: data.get("name"), email: data.get("email"), password: data.get("password") }
        : { email: data.get("email"), password: data.get("password") };
      const response = await api(register ? "auth/register" : "auth/login", { method: "POST", body: JSON.stringify(body) });
      localStorage.setItem("runvibe.token", response.accessToken);
      onSuccess();
    } catch (e) { setError(e instanceof Error ? e.message : "Falha ao entrar."); }
    finally { setLoading(false); }
  }
  return (
    <div className="login-page">
      <section className="login-story">
        <div className="login-brand"><span className="brand-mark">R</span> RUNVIBE</div>
        <div><p className="eyebrow light">CORRA COM PROPÓSITO</p><h1>Todo treino conta.<br />Toda evolução conecta.</h1><p>GPS, comunidade e orientação inteligente em uma única experiência.</p></div>
        <div className="login-stats"><span><strong>GPS</strong> em tempo real</span><span><strong>OFFLINE</strong> sem perder a corrida</span><span><strong>IA</strong> para evoluir</span></div>
      </section>
      <section className="login-form-wrap">
        <form className="login-card" onSubmit={submit}>
          <span className="brand-mark mobile-brand">R</span>
          <p className="eyebrow">{register ? "COMECE AGORA" : "BEM-VINDO DE VOLTA"}</p>
          <h2>{register ? "Crie sua conta" : "Entre no RunVibe"}</h2>
          {register && <label>Nome<input name="name" required minLength={2} placeholder="Seu nome" /></label>}
          <label>E-mail<input name="email" required type="email" placeholder="voce@email.com" /></label>
          <label>Senha<input name="password" required type="password" minLength={8} placeholder="Mínimo de 8 caracteres" /></label>
          {error && <div className="error-box">{error}</div>}
          <button className="primary full" disabled={loading}>{loading ? "Conectando ao servidor…" : register ? "Criar conta" : "Entrar"}</button>
          {loading && <small>O servidor gratuito pode levar até 3 minutos no primeiro acesso.</small>}
          <button type="button" className="text-button" onClick={() => setRegister(!register)}>{register ? "Já tenho uma conta" : "Ainda não tenho uma conta"}</button>
        </form>
      </section>
    </div>
  );
}

function Dashboard({ onRecord, onCoach, notify }: { onRecord: () => void; onCoach: () => void; notify: (m:string) => void }) {
  const [feed, setFeed] = useState<FeedItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [mode,setMode]=useState<"community"|"mine">("community");
  const [myId,setMyId]=useState("");
  const loadFeed = () => {
    setLoading(true);
    api("feed?size=10").then((r) => setFeed(r.content || [])).catch(() => {
      const drafts: Draft[] = JSON.parse(localStorage.getItem("runvibe.drafts") || "[]");
      setFeed(drafts.map((d) => ({ title: "Atividade salva no aparelho", sportType: d.sportType, totalDistanceMeters: d.distance, elapsedTimeSeconds: d.elapsed, createdAt: d.startTime })));
    }).finally(() => setLoading(false));
  };
  useEffect(() => { loadFeed(); api("users/me").then(profile=>setMyId(profile.id||"")).catch(()=>undefined); }, []);
  const visibleFeed=mode==="mine"&&myId?feed.filter(activity=>activity.userId===myId):feed;
  const total = visibleFeed.reduce((sum, a) => sum + (a.totalDistanceMeters || 0), 0);
  return (
    <div className="content-grid">
      <section className="hero-card">
        <div><span className="status-pill">SEMANA ATUAL</span><h2>Pronto para o próximo quilômetro?</h2><p>Consistência vence intensidade sem direção.</p><button className="primary" onClick={onRecord}>● Iniciar atividade</button></div>
        <div className="week-ring"><strong>{(total / 1000).toFixed(1)}</strong><span>km esta semana</span></div>
      </section>
      <section className="stats-row">
        <Stat label="DISTÂNCIA" value={`${(total / 1000).toFixed(1)} km`} trend="esta semana" />
        <Stat label="ATIVIDADES" value={`${visibleFeed.length}`} trend="registradas" />
        <Stat label="TEMPO ATIVO" value={clock(visibleFeed.reduce((s,a) => s + (a.elapsedTimeSeconds || 0), 0))} trend="em movimento" />
      </section>
      <section className="feed-section">
        <div className="section-title"><div><p className="eyebrow">{mode==="mine"?"HISTÓRICO PESSOAL":"COMUNIDADE"}</p><h2>{mode==="mine"?"Meus treinos":"Atividades recentes"}</h2></div><div className="feed-actions"><button className={mode==="community"?"secondary selected":"text-button"} onClick={()=>setMode("community")}>Colegas</button><button className={mode==="mine"?"secondary selected":"text-button"} onClick={()=>setMode("mine")}>Meus treinos</button><button className="text-button" onClick={loadFeed}>Atualizar</button></div></div>
        {loading ? <div className="empty-card">Carregando atividades…</div> : visibleFeed.length === 0 ? <div className="empty-card"><strong>{mode==="mine"?"Nenhum treino sincronizado.":"Sua jornada começa aqui."}</strong><span>{mode==="mine"?"Finalize e salve uma atividade para consultar suas parciais.":"Grave a primeira atividade ou encontre amigos."}</span><button className="primary" onClick={onRecord}>Gravar agora</button></div> :
          visibleFeed.map((a, i) => <ActivityCard key={a.id || i} activity={a} notify={notify} />)}
      </section>
      <aside className="right-rail">
        <div className="rail-card accent"><p className="eyebrow">TREINO DO DIA</p><h3>Corrida leve</h3><strong>35 min</strong><p>Ritmo confortável, respiração controlada.</p><button className="secondary" onClick={onCoach}>Ver treino</button></div>
        <div className="rail-card"><p className="eyebrow">PRÓXIMA PROVA</p><h3>Maratona do Rio</h3><p>Rio de Janeiro · Junho</p><div className="countdown"><strong>42</strong><span>dias</span></div></div>
      </aside>
    </div>
  );
}
function Stat({ label, value, trend }: { label: string; value: string; trend: string }) { return <div className="stat-card"><span>{label}</span><strong>{value}</strong><small>{trend}</small></div>; }
function ActivityCard({ activity, notify }: { activity: FeedItem; notify:(m:string)=>void }) {
  const [liked,setLiked]=useState(false);
  const [commentsOpen,setCommentsOpen]=useState(false);
  const [comments,setComments]=useState<ActivityComment[]>([]);
  const [commentsLoading,setCommentsLoading]=useState(false);
  const [comment,setComment]=useState("");
  const [sending,setSending]=useState(false);
  const [details,setDetails]=useState<FeedItem|null>(null);
  const [detailsLoading,setDetailsLoading]=useState(false);
  async function kudos(){ if(!activity.id) return notify("Esta atividade ainda está apenas no aparelho."); try{const r=await api(`activities/${activity.id}/kudos`,{method:"POST"});setLiked(r.active);notify(r.active?"Kudos enviado!":"Kudos removido.");}catch(e){notify(e instanceof Error?e.message:"Falha ao enviar Kudos.");}}
  async function share(){const text=`${activity.title || "Atividade"} · ${((activity.totalDistanceMeters||0)/1000).toFixed(2)} km no RunVibe`;if(navigator.share) await navigator.share({title:"RunVibe",text});else{await navigator.clipboard.writeText(text);notify("Resumo copiado.");}}
  async function toggleComments(){
    const opening=!commentsOpen; setCommentsOpen(opening);
    if(!opening || !activity.id || comments.length) return;
    setCommentsLoading(true);
    try{setComments(await api(`activities/${activity.id}/comments`));}
    catch(e){notify(e instanceof Error?e.message:"Não foi possível carregar os comentários.");}
    finally{setCommentsLoading(false);}
  }
  async function sendComment(event:FormEvent<HTMLFormElement>){
    event.preventDefault();
    const content=comment.trim();
    if(!activity.id || !content || sending) return;
    setSending(true);
    try{
      const created=await api(`activities/${activity.id}/comments`,{method:"POST",body:JSON.stringify({content})});
      setComments(old=>[...old,created]); setComment(""); notify("Comentário publicado.");
    }catch(e){notify(e instanceof Error?e.message:"Não foi possível comentar.");}
    finally{setSending(false);}
  }
  async function toggleDetails(){
    if(details){setDetails(null);return;}
    if(!activity.id)return notify("Este treino ainda está somente neste aparelho.");
    setDetailsLoading(true);
    try{setDetails(await api(`activities/${activity.id}`));}
    catch(e){notify(e instanceof Error?e.message:"Não foi possível abrir o treino.");}
    finally{setDetailsLoading(false);}
  }
  const sportLabel=({CYCLING:"Ciclismo",WALKING:"Caminhada",HIKING:"Trilha",RUNNING:"Corrida"} as Record<string,string>)[activity.sportType||"RUNNING"]||"Atividade";
  return <article className="activity-card">
    <div className="activity-head"><div className="mini-avatar">{(activity.userName||"Você").slice(0,1).toUpperCase()}</div><div><strong>{activity.userName || "Você"}</strong><span>{new Date(activity.createdAt || Date.now()).toLocaleDateString("pt-BR", { day:"2-digit", month:"long" })}</span></div><span className="sport-pill">{sportLabel}</span></div>
    <h3>{activity.title || `${sportLabel} ao ar livre`}</h3>
    <div className="activity-map"><div className="route-line" /></div>
    <div className="activity-metrics"><span><b>{((activity.totalDistanceMeters || 0)/1000).toFixed(2)}</b> km</span><span><b>{clock(activity.elapsedTimeSeconds || 0)}</b> tempo</span><span><b>{pace(activity.averagePaceSecondsPerKm || 0)}</b> ritmo</span></div>
    <button className="activity-details-button" onClick={toggleDetails}>{details?"Ocultar detalhes":detailsLoading?"Carregando…":"Ver treino e parciais"} <span>›</span></button>
    {details&&<section className="activity-details">
      {details.description&&<p>{details.description}</p>}
      <div className="detail-metrics"><span><small>Tempo em movimento</small><b>{clock(details.movingTimeSeconds||0)}</b></span><span><small>Ganho de elevação</small><b>{Math.round(details.elevationGainMeters||0)} m</b></span><span><small>Ritmo médio</small><b>{pace(details.averagePaceSecondsPerKm||0)}</b></span></div>
      <h4>Parciais por quilômetro</h4>
      {details.splits?.length?<div className="splits-table"><div className="split-head"><span>KM</span><span>Tempo</span><span>Ritmo</span></div>{details.splits.map(split=><div className="split-row" key={split.kilometer}><strong>{split.kilometer}</strong><span>{clock(split.durationSeconds)}</span><span>{pace(split.paceSecondsPerKm)}</span></div>)}</div>:<p className="comments-status">Não há parciais disponíveis para este treino.</p>}
    </section>}
    <div className="social-row"><button className={liked?"liked":""} onClick={kudos}>{liked?"♥":"♡"} Kudos</button><button className={commentsOpen?"active":""} onClick={toggleComments}>○ {comments.length ? `${comments.length} comentário${comments.length===1?"":"s"}` : "Comentar"}</button><button onClick={share}>↗ Compartilhar</button></div>
    {commentsOpen&&<section className="comments-panel">
      {commentsLoading?<p className="comments-status">Carregando comentários…</p>:comments.length===0?<p className="comments-status">Seja a primeira pessoa a comentar este treino.</p>:<div className="comment-list">{comments.map(item=><div className="comment-item" key={item.id}><div className="comment-avatar">{item.userName.slice(0,1).toUpperCase()}</div><div><p><strong>{item.userName}</strong> {item.content}</p><time>{new Date(item.createdAt).toLocaleString("pt-BR",{day:"2-digit",month:"short",hour:"2-digit",minute:"2-digit"})}</time></div></div>)}</div>}
      {activity.id&&<form className="comment-form" onSubmit={sendComment}><input value={comment} onChange={e=>setComment(e.target.value)} maxLength={1000} placeholder="Escreva um comentário…" aria-label="Comentário"/><button className="primary" disabled={sending||!comment.trim()}>{sending?"Enviando…":"Publicar"}</button></form>}
    </section>}
  </article>;
}

function Recorder({ notify }: { notify: (m: string) => void }) {
  const [status, setStatus] = useState<"idle"|"running"|"paused"|"saved">("idle");
  const [elapsed, setElapsed] = useState(0), [moving, setMoving] = useState(0), [distance, setDistance] = useState(0);
  const [points, setPoints] = useState<Point[]>([]), [sport, setSport] = useState("RUNNING"), [gps, setGps] = useState("Aguardando GPS");
  const watch = useRef<number | null>(null), timer = useRef<ReturnType<typeof setInterval> | null>(null), started = useRef("");
  const currentPace = distance > 0 ? Math.round(moving / (distance / 1000)) : 0;

  useEffect(() => () => { if (watch.current !== null) navigator.geolocation.clearWatch(watch.current); if (timer.current) clearInterval(timer.current); }, []);
  function startWatch() {
    if (!navigator.geolocation) return notify("Este navegador não oferece GPS.");
    watch.current = navigator.geolocation.watchPosition((position) => {
      const p: Point = { latitude: position.coords.latitude, longitude: position.coords.longitude, elevation: position.coords.altitude || 0, speedMs: Math.max(0, position.coords.speed || 0), heartRate: 0, timestamp: new Date(position.timestamp).toISOString() };
      setPoints((old) => {
        if (old.length) { const delta = haversine(old[old.length - 1], p); if (delta < 100) setDistance((d) => d + delta); }
        return [...old, p];
      });
      setGps(`GPS ativo · ±${Math.round(position.coords.accuracy)} m`);
    }, (error) => setGps(error.code === 1 ? "Permissão de GPS negada" : "Buscando sinal GPS…"), { enableHighAccuracy: true, maximumAge: 0, timeout: 15000 });
  }
  function start() {
    started.current = new Date().toISOString(); setStatus("running"); setGps("Buscando sinal GPS…"); startWatch();
    timer.current = setInterval(() => { setElapsed((v) => v + 1); setMoving((v) => v + 1); }, 1000);
  }
  function pauseRun() {
    if (status === "running") { setStatus("paused"); if (timer.current) clearInterval(timer.current); if (watch.current !== null) navigator.geolocation.clearWatch(watch.current); }
    else { setStatus("running"); startWatch(); timer.current = setInterval(() => { setElapsed((v) => v + 1); setMoving((v) => v + 1); }, 1000); }
  }
  function discard() { if (!confirm("Descartar esta atividade?")) return; reset(); }
  function reset() { if (timer.current) clearInterval(timer.current); if (watch.current !== null) navigator.geolocation.clearWatch(watch.current); setStatus("idle"); setElapsed(0); setMoving(0); setDistance(0); setPoints([]); setGps("Aguardando GPS"); }
  async function finish() {
    if (timer.current) clearInterval(timer.current); if (watch.current !== null) navigator.geolocation.clearWatch(watch.current);
    const draft: Draft = { localId: crypto.randomUUID(), startTime: started.current, elapsed, moving, distance, points, sportType: sport, pending: true };
    const drafts: Draft[] = JSON.parse(localStorage.getItem("runvibe.drafts") || "[]"); localStorage.setItem("runvibe.drafts", JSON.stringify([draft, ...drafts]));
    if (points.length >= 2 && elapsed > 0) {
      try {
        await api("activities", { method:"POST", body: JSON.stringify({ title: sports.find(s => s[0] === sport)?.[1] || "Atividade", description:"Registrada pelo RunVibe Web", sportType:sport, elapsedTimeSeconds:Math.max(1,elapsed), movingTimeSeconds:Math.max(1,Math.min(moving,elapsed)), points }) });
        draft.pending = false; localStorage.setItem("runvibe.drafts", JSON.stringify([draft, ...drafts])); notify("Atividade salva e sincronizada!");
      } catch { notify("Atividade salva no aparelho. Sincronizaremos depois."); }
    } else notify("Atividade salva no aparelho, sem rota GPS completa.");
    setStatus("saved");
  }
  return (
    <div className="recorder-layout">
      <section className="recorder-map"><RouteCanvas points={points} /><div className={`gps-badge ${gps.includes("ativo") ? "ok" : ""}`}>● {gps}</div><div className="map-warning">No iPhone, mantenha esta tela aberta durante a atividade.</div></section>
      <section className="recorder-panel">
        <select value={sport} disabled={status === "running" || status === "paused"} onChange={(e) => setSport(e.target.value)}>{sports.map(s => <option key={s[0]} value={s[0]}>{s[1]}</option>)}</select>
        <div className="big-time">{clock(elapsed)}</div><span className="big-label">TEMPO TOTAL</span>
        <div className="record-stats"><div><strong>{(distance/1000).toFixed(2)}</strong><span>quilômetros</span></div><div><strong>{pace(currentPace)}</strong><span>ritmo médio</span></div></div>
        {status === "idle" || status === "saved" ? <button className="start-button" onClick={start}>INICIAR</button> :
          <div className="record-controls"><button className="round ghost" onClick={discard}>↺<span>Zerar</span></button><button className="round main" onClick={pauseRun}>{status === "paused" ? "▶" : "Ⅱ"}<span>{status === "paused" ? "Continuar" : "Pausar"}</span></button><button className="round stop" onClick={finish}>■<span>Finalizar</span></button></div>}
        <div className="offline-note"><span>✓</span><div><strong>Proteção offline ativa</strong><p>Se a conexão cair, o treino permanece neste aparelho.</p></div></div>
      </section>
    </div>
  );
}

function RouteCanvas({ points }: { points: Point[] }) {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const c = ref.current; if (!c) return; const ctx = c.getContext("2d"); if (!ctx) return;
    const ratio = devicePixelRatio || 1, rect = c.getBoundingClientRect(); c.width = rect.width * ratio; c.height = rect.height * ratio; ctx.scale(ratio,ratio);
    ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue("--map"); ctx.fillRect(0,0,rect.width,rect.height);
    ctx.strokeStyle = getComputedStyle(document.documentElement).getPropertyValue("--map-grid"); ctx.lineWidth=1;
    for(let x=0;x<rect.width;x+=42){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,rect.height);ctx.stroke();}
    for(let y=0;y<rect.height;y+=42){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(rect.width,y);ctx.stroke();}
    if(points.length<2) return;
    const lats=points.map(p=>p.latitude), lons=points.map(p=>p.longitude), minLat=Math.min(...lats), maxLat=Math.max(...lats), minLon=Math.min(...lons), maxLon=Math.max(...lons), pad=50;
    ctx.strokeStyle="#b7f34a";ctx.lineWidth=6;ctx.lineCap="round";ctx.lineJoin="round";ctx.beginPath();
    points.forEach((p,i)=>{const x=pad+(p.longitude-minLon)/(maxLon-minLon||1)*(rect.width-pad*2),y=rect.height-pad-(p.latitude-minLat)/(maxLat-minLat||1)*(rect.height-pad*2);i?ctx.lineTo(x,y):ctx.moveTo(x,y);});ctx.stroke();
  },[points]);
  return <canvas ref={ref} />;
}

function Coach({ notify }: { notify:(m:string)=>void }) {
  const [goal,setGoal]=useState("10 km"),[level,setLevel]=useState("Iniciante"),[days,setDays]=useState(3),[km,setKm]=useState(15),[generated,setGenerated]=useState(false);
  const plan=useMemo(()=>[
    ["Corrida leve",`${Math.max(4,km/days).toFixed(1)} km · ritmo confortável`],
    ["Treino de tiros",`${level==="Iniciante"?6:8} × 1 min forte · 90 s trotando`],
    ["Fartlek","10 min leve + 8 × (1 min rápido / 1 min livre)"],
    ["Longão",`${Math.min(goal==="21 km"?18:10,km*.45).toFixed(1)} km · esforço fácil`],
  ],[goal,level,days,km]);
  return <div className="coach-grid"><section className="form-card"><p className="eyebrow">PLANO PERSONALIZADO</p><h2>Conte ao treinador onde você quer chegar.</h2><label>Objetivo<select value={goal} onChange={e=>setGoal(e.target.value)}><option>5 km</option><option>10 km</option><option>21 km</option><option>42 km</option></select></label><label>Nível<select value={level} onChange={e=>setLevel(e.target.value)}><option>Iniciante</option><option>Intermediário</option><option>Avançado</option></select></label><label>Dias por semana <b>{days}</b><input type="range" min="2" max="6" value={days} onChange={e=>setDays(+e.target.value)} /></label><label>Volume atual <b>{km} km/semana</b><input type="range" min="5" max="100" step="5" value={km} onChange={e=>setKm(+e.target.value)} /></label><button className="primary full" onClick={()=>{setGenerated(true);localStorage.setItem("runvibe.plan",JSON.stringify({goal,level,days,km,plan}));notify("Plano personalizado criado e salvo.");}}>✦ Criar meu plano</button></section><section className="plan-card"><p className="eyebrow">SEMANA 1</p><h2>{generated?"Seu plano inicial":"Prévia do seu plano"}</h2>{plan.map((p,i)=><div className="workout-row" key={p[0]}><span>{i+1}</span><div><strong>{p[0]}</strong><p>{p[1]}</p></div><button aria-label={`Detalhes de ${p[0]}`} onClick={()=>notify(`${p[0]}: ${p[1]}`)}>›</button></div>)}<small>Recomendação esportiva, não médica. Ajuste a carga em caso de dor ou mal-estar.</small></section></div>;
}
type Person = {id:string;name:string;email:string;bio?:string;profilePictureUrl?:string;followersCount:number;followingCount:number;followedByMe:boolean};
function People({notify}:{notify:(m:string)=>void}) {
  const [query,setQuery]=useState(""),[people,setPeople]=useState<Person[]>([]),[loading,setLoading]=useState(true);
  async function search(value=query){setLoading(true);try{setPeople(await api(`users/search?query=${encodeURIComponent(value.trim())}`));}catch(e){notify(e instanceof Error?e.message:"Não foi possível carregar pessoas.");}finally{setLoading(false);}}
  useEffect(()=>{search("");},[]);
  useEffect(()=>{const id=setTimeout(()=>search(query),350);return()=>clearTimeout(id);},[query]);
  async function follow(person:Person){try{const r=await api(`users/${person.id}/follow`,{method:"POST"});setPeople(list=>list.map(p=>p.id===person.id?{...p,followedByMe:r.active,followersCount:Math.max(0,p.followersCount+(r.active?1:-1))}:p));notify(r.active?`Você agora segue ${person.name}.`:`Você deixou de seguir ${person.name}.`);}catch(e){notify(e instanceof Error?e.message:"Não foi possível atualizar.");}}
  return <section className="people-page"><div className="people-hero"><div><p className="eyebrow">COMUNIDADE RUNVIBE</p><h2>Treinar junto muda tudo.</h2><p>Descubra pessoas cadastradas, acompanhe suas atividades e compartilhe evolução.</p></div><div className="people-count"><strong>{people.length}</strong><span>pessoas encontradas</span></div></div><div className="people-toolbar"><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Buscar por nome ou e-mail" aria-label="Buscar pessoas"/><button className="primary" onClick={()=>search()}>Buscar</button></div>{loading?<div className="empty-card">Buscando pessoas…</div>:people.length===0?<div className="empty-card"><strong>Nenhuma pessoa encontrada.</strong><span>Tente outro nome ou e-mail.</span></div>:<div className="people-grid">{people.map(person=><article className="person-card" key={person.id}><div className="person-avatar">{person.name.slice(0,2).toUpperCase()}</div><div className="person-info"><h3>{person.name}</h3><p>{person.bio || person.email}</p><span>{person.followersCount} seguidores · {person.followingCount} seguindo</span></div><button className={person.followedByMe?"secondary":"primary"} onClick={()=>follow(person)}>{person.followedByMe?"Seguindo":"Seguir"}</button></article>)}</div>}</section>;
}
function Clubs({notify}:{notify:(m:string)=>void}) { const [joined,setJoined]=useState<string[]>(()=>JSON.parse(localStorage.getItem("runvibe.clubs")||"[]")); const clubs=[["RunVibe Rio","Rio de Janeiro","1.284"],["Longão de Domingo","Brasil","846"],["Pedal RunVibe","Brasil","612"]]; const toggle=(n:string)=>{const next=joined.includes(n)?joined.filter(x=>x!==n):[...joined,n];setJoined(next);localStorage.setItem("runvibe.clubs",JSON.stringify(next));notify(joined.includes(n)?"Você saiu do clube.":"Bem-vindo ao clube!");}; return <CardGrid eyebrow="ENCONTRE SUA TRIBO" title="Clubes em destaque">{clubs.map(c=><article className="club-card" key={c[0]}><div className="club-cover">RV</div><h3>{c[0]}</h3><p>{c[1]} · {c[2]} membros</p><button className={joined.includes(c[0])?"secondary":"primary"} onClick={()=>toggle(c[0])}>{joined.includes(c[0])?"Participando":"Participar"}</button></article>)}</CardGrid>; }
function Races({notify}:{notify:(m:string)=>void}) { const races=[["Maratona do Rio","Rio de Janeiro","21 JUN","5K · 10K · 21K · 42K"],["São Silvestre","São Paulo","31 DEZ","15K"],["Meia de Floripa","Florianópolis","23 AGO","5K · 21K"]]; return <CardGrid eyebrow="CALENDÁRIO NACIONAL" title="Encontre seu próximo desafio">{races.map(r=><article className="race-card" key={r[0]}><div className="race-date">{r[2]}</div><div><h3>{r[0]}</h3><p>{r[1]}</p><strong>{r[3]}</strong></div><button className="secondary" onClick={()=>notify("Abriremos a inscrição oficial em uma nova página.")}>Ver prova</button></article>)}</CardGrid>; }
function CardGrid({eyebrow,title,children}:{eyebrow:string;title:string;children:React.ReactNode}) { return <section className="directory"><p className="eyebrow">{eyebrow}</p><h2>{title}</h2><div className="card-grid">{children}</div></section>; }
function Profile({onLogout}:{onLogout:()=>void}) {
  const [profile,setProfile]=useState({name:"Corredor RunVibe",bio:"Em busca do próximo quilômetro.",followersCount:0,followingCount:0,profilePictureUrl:""}),[editing,setEditing]=useState(false),[message,setMessage]=useState(""),[localPhoto,setLocalPhoto]=useState("");
  useEffect(()=>{setLocalPhoto(localStorage.getItem("runvibe.profilePhoto")||"");api("users/me").then(p=>setProfile({...profile,...p})).catch(()=>setMessage("Perfil disponível em modo offline."));},[]);
  function choosePhoto(file?:File){
    if(!file)return;
    if(!file.type.startsWith("image/"))return setMessage("Escolha uma imagem válida.");
    if(file.size>8*1024*1024)return setMessage("A foto deve ter no máximo 8 MB.");
    const reader=new FileReader();
    reader.onload=()=>{const image=new Image();image.onload=()=>{const size=512,canvas=document.createElement("canvas");canvas.width=size;canvas.height=size;const ctx=canvas.getContext("2d");if(!ctx)return;const side=Math.min(image.width,image.height),sx=(image.width-side)/2,sy=(image.height-side)/2;ctx.drawImage(image,sx,sy,side,side,0,0,size,size);const data=canvas.toDataURL("image/jpeg",.82);localStorage.setItem("runvibe.profilePhoto",data);setLocalPhoto(data);setMessage("Foto atualizada neste aparelho.");};image.src=String(reader.result);};
    reader.readAsDataURL(file);
  }
  async function save(event:FormEvent<HTMLFormElement>){event.preventDefault();const data=new FormData(event.currentTarget);try{const updated=await api("users/me",{method:"PATCH",body:JSON.stringify({name:data.get("name"),bio:data.get("bio"),profilePictureUrl:profile.profilePictureUrl||null})});setProfile({...profile,...updated});setEditing(false);setMessage("Perfil atualizado.");}catch(e){setMessage(e instanceof Error?e.message:"Falha ao atualizar.");}}
  return <div className="profile-layout"><section className="profile-card"><div className="profile-photo-wrap">{localPhoto||profile.profilePictureUrl?<img className="profile-photo" src={localPhoto||profile.profilePictureUrl} alt={`Foto de ${profile.name}`}/>:<div className="profile-avatar">{profile.name.slice(0,2).toUpperCase()}</div>}<label className="photo-button" title="Alterar foto">＋<input type="file" accept="image/jpeg,image/png,image/webp" capture="user" onChange={e=>choosePhoto(e.target.files?.[0])}/></label></div>{editing?<form className="profile-form" onSubmit={save}><label>Nome<input name="name" defaultValue={profile.name} minLength={2} required/></label><label>Biografia<textarea name="bio" defaultValue={profile.bio} maxLength={300}/></label><div><button type="button" className="secondary" onClick={()=>setEditing(false)}>Cancelar</button><button className="primary">Salvar alterações</button></div></form>:<><h2>{profile.name}</h2><p>{profile.bio}</p><div className="profile-numbers"><span><b>{profile.followersCount}</b> seguidores</span><span><b>{profile.followingCount}</b> seguindo</span></div><button className="secondary" onClick={()=>setEditing(true)}>Editar perfil</button></>}{message&&<small className="profile-message">{message}</small>}</section><section className="settings-card"><h3>Conta e preferências</h3><button onClick={()=>setMessage("Seu perfil é visível para a comunidade RunVibe.")}>Privacidade <span>›</span></button><button onClick={()=>setMessage("As notificações do navegador dependem da sua permissão.")}>Notificações <span>›</span></button><button onClick={()=>setMessage("A integração com Health Connect e Stratos 4 está em desenvolvimento.")}>Dispositivos e relógios <span>›</span></button><button onClick={()=>setMessage("Atividades pendentes permanecem protegidas neste aparelho.")}>Dados e sincronização <span>›</span></button><button className="danger-text" onClick={onLogout}>Sair da conta</button></section></div>;
}
