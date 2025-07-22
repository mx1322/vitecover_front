import { ProductListDocument } from "@/gql/graphql";
import { executeGraphQL } from "@/lib/graphql";
import { ProductList } from "@/ui/components/ProductList";

export const metadata = {
	title: "ACME Storefront, powered by Saleor & Next.js",
	description:
		"Storefront Next.js Example for building performant e-commerce experiences with Saleor - the composable, headless commerce platform for global brands.",
};

export default async function Page(props: { params: Promise<{ channel: string }> }) {
	const params = await props.params;
	const { products } = await executeGraphQL(ProductListDocument, {
		variables: {
			first: 12,
			channel: params.channel,
		},
		revalidate: 60,
	});

	if (!products) {
		return (
			<section className="mx-auto max-w-7xl p-8 pb-16">
				<h2 className="text-center text-xl font-semibold">No products available</h2>
			</section>
		);
	}

	const productList = products.edges.map(({ node: product }) => product);

	return (
		<section className="mx-auto max-w-7xl p-8 pb-16">
			<h2 className="sr-only">Product list</h2>
			<ProductList products={productList} />
		</section>
	);
}
