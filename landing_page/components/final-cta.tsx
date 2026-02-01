"use client"

import { Button } from "@/components/ui/button"
import { ArrowRight } from "lucide-react"

export function FinalCTA() {
  return (
    <section className="py-24 px-6">
      <div className="max-w-3xl mx-auto text-center">
        <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-6 text-balance">
          Ready to let go of the mental clutter?
        </h2>
        <p className="text-lg text-muted-foreground mb-10 max-w-xl mx-auto text-pretty">
          Try FollowUP today. No signup required, no pressure. Just a simpler way to keep track of what matters.
        </p>
        <Button size="lg" className="rounded-full px-10 gap-2" asChild>
          <a href="#demo">
            Try the Demo
            <ArrowRight className="w-4 h-4" />
          </a>
        </Button>
      </div>
    </section>
  )
}
