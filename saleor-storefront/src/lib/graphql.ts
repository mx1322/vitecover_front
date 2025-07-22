import { invariant } from "ts-invariant";
import { type TypedDocumentString } from "../gql/graphql";
import { getServerAuthClient } from "@/app/config";

type GraphQLErrorResponse = {
	errors: readonly {
		message: string;
	}[];
};

type GraphQLRespone<T> = { data: T } | GraphQLErrorResponse;

export async function executeGraphQL<Result, Variables>(
	operation: TypedDocumentString<Result, Variables>,
	options: {
		headers?: HeadersInit;
		cache?: RequestCache;
		revalidate?: number;
		withAuth?: boolean;
	} & (Variables extends Record<string, never> ? { variables?: never } : { variables: Variables }),
): Promise<Result> {
	const saleorApiUrl =
		typeof window === "undefined"
			? process.env.SALEOR_API_URL
			: process.env.NEXT_PUBLIC_SALEOR_API_URL;
	invariant(saleorApiUrl, "Missing SALEOR_API_URL or NEXT_PUBLIC_SALEOR_API_URL env variable");

	const { variables, headers, cache, revalidate, withAuth = true } = options;

	const input = {
		method: "POST",
		headers: {
			"Content-Type": "application/json",
			...headers,
		},
		body: JSON.stringify({
			query: operation.toString(),
			...(variables && { variables }),
		}),
		cache: cache,
		next: { revalidate },
	};

	const response = withAuth
		? await (await getServerAuthClient()).fetchWithAuth(saleorApiUrl, input)
		: await fetch(saleorApiUrl, input);

	if (!response.ok) {
		console.error(input.body);
		throw new HTTPError(response);
	}

	const body = (await response.json()) as GraphQLRespone<Result>;

	if ("errors" in body) {
		throw new GraphQLError(body);
	}

	return body.data;
}

class GraphQLError extends Error {
	constructor(public errorResponse: GraphQLErrorResponse) {
		const message = errorResponse.errors.map((error) => error.message).join("\n");
		super(message);
		this.name = this.constructor.name;
		Object.setPrototypeOf(this, new.target.prototype);
	}
}
class HTTPError extends Error {
	response: Response;
	constructor(response: Response) {
		const message = `HTTP error ${response.status}: ${response.statusText}}`;
		super(message);
		this.name = this.constructor.name;
		this.response = response;
		Object.setPrototypeOf(this, new.target.prototype);
	}
}
