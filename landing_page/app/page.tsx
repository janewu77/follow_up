import { Header } from "@/components/header"
import { Hero } from "@/components/hero"
import { Problem } from "@/components/problem"
import { HowItWorks } from "@/components/how-it-works"
import { Demo } from "@/components/demo"
import { MindfulnessTrust } from "@/components/mindfulness-trust"
import { Pricing } from "@/components/pricing"
import { FAQ } from "@/components/faq"
import { Footer } from "@/components/footer"

export default function Home() {
  return (
    <main className="min-h-screen bg-background">
      <Header />
      <Hero />
      <Problem />
      <HowItWorks />
      <Demo />
      <MindfulnessTrust />
      <Pricing />
      <FAQ />
      <Footer />
    </main>
  )
}
