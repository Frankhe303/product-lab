export default {
  async fetch(request, env) {
    return new Response(HTML, {
      headers: { 'Content-Type': 'text/html; charset=utf-8' }
    });
  }
};

const HTML = `__HTML_PLACEHOLDER__`;
