import { env, createExecutionContext, waitOnExecutionContext, SELF } from 'cloudflare:test';
import { describe, it, expect } from 'vitest';
import worker, { Env } from '../src/index';

const IncomingRequest = Request<unknown, IncomingRequestCfProperties>;

const mockEnv = env as unknown as Env;

describe('Cloudflare Worker', () => {
	it('responds with Hello World! on GET /', async () => {
		const request = new IncomingRequest('http://example.com/');
		const ctx = createExecutionContext();
		const response = await worker.fetch(request, mockEnv, ctx);
		await waitOnExecutionContext(ctx);
		expect(await response.text()).toMatchInlineSnapshot(`"Hello World!"`);
	});

	it('responds with 405 on POST /', async () => {
		const request = new IncomingRequest('http://example.com/', { method: 'POST' });
		const ctx = createExecutionContext();
		const response = await worker.fetch(request, mockEnv, ctx);
		await waitOnExecutionContext(ctx);
		expect(response.status).toBe(405);
	});

	it('responds with 405 on GET unknown path', async () => {
		const request = new IncomingRequest('http://example.com/unknown');
		const ctx = createExecutionContext();
		const response = await worker.fetch(request, mockEnv, ctx);
		await waitOnExecutionContext(ctx);
		expect(response.status).toBe(405);
	});
});
