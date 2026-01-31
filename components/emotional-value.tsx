"use client"

import { Sparkles, Heart, Leaf } from "lucide-react"

const values = [
  {
    icon: Sparkles,
    title: "Less mental load",
    description: "Stop carrying the stress of remembering every appointment, event, and deadline in your head."
  },
  {
    icon: Heart,
    title: "More presence",
    description: "When you know nothing will slip through the cracks, you can fully enjoy the moment you're in."
  },
  {
    icon: Leaf,
    title: "Calm, not chaos",
    description: "This isn't about productivity hacks. It's about creating space for what actually matters to you."
  }
]

export function EmotionalValue() {
  return (
    <section className="py-24 px-6">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Feel the difference
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            FollowUP helps you live a more balanced and present life — not by doing more, but by worrying less.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {values.map((value) => (
            <div 
              key={value.title}
              className="text-center p-8 rounded-3xl bg-card border border-border/50"
            >
              <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center mx-auto mb-6">
                <value.icon className="w-8 h-8 text-primary" />
              </div>
              <h3 className="text-xl font-semibold text-foreground mb-3">
                {value.title}
              </h3>
              <p className="text-muted-foreground leading-relaxed">
                {value.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
