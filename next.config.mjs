/** @type {import('next').NextConfig} */
const nextConfig = {
  // The container image (Dockerfile) builds with NEXT_OUTPUT=standalone.
  ...(process.env.NEXT_OUTPUT === "standalone"
    ? {
        output: "standalone",
      }
    : {}),
  // Other zyx.tw sites render scenes with <Scene3D>, which loads its
  // environment maps from here.
  async headers() {
    return [
      {
        source: "/env/:path*",
        headers: [{ key: "Access-Control-Allow-Origin", value: "*" }],
      },
    ]
  },
}

export default nextConfig
