type Handler = () => void;

const handlers = new Set<Handler>();

export function onSessionExpired(handler: Handler): () => void {
  handlers.add(handler);
  return () => handlers.delete(handler);
}

export function notifySessionExpired(): void {
  for (const handler of handlers) handler();
}
