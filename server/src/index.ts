export interface Env {
	GOOGLE_CLIENT_ID: string;
	GOOGLE_CLIENT_SECRET: string;
}

interface OAuthRequest {
	code: string;
}

interface RefreshTokenRequest {
	refresh_token: string;
}

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);

		if (request.method === 'POST' && url.pathname === '/api/oauth') {
			const body = await request.json<OAuthRequest>();

			const response = await fetch('https://oauth2.googleapis.com/token', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/x-www-form-urlencoded',
				},
				body: new URLSearchParams({
					client_id: env.GOOGLE_CLIENT_ID,
					client_secret: env.GOOGLE_CLIENT_SECRET,
					code: body.code,
					grant_type: 'authorization_code',
					redirect_uri: 'https://heartry.darshanrander.com/',
				}),
			});

			const data = await response.text();
			return new Response(data, {
				status: response.status,
				headers: { 'Content-Type': 'application/json' },
			});
		}

		if (request.method === 'POST' && url.pathname === '/api/refresh_token') {
			const body = await request.json<RefreshTokenRequest>();

			const response = await fetch('https://oauth2.googleapis.com/token', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/x-www-form-urlencoded',
				},
				body: new URLSearchParams({
					client_id: env.GOOGLE_CLIENT_ID,
					client_secret: env.GOOGLE_CLIENT_SECRET,
					refresh_token: body.refresh_token,
					grant_type: 'refresh_token',
				}),
			});

			const data = await response.text();
			return new Response(data, {
				status: response.status,
				headers: { 'Content-Type': 'application/json' },
			});
		}

		if (request.method === 'GET' && url.pathname === '/') {
			return new Response('Hello World!');
		}

		return new Response('Method not allowed', { status: 405 });
	},
} satisfies ExportedHandler<Env>;
