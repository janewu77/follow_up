"use client"

import { Shield, UserX, Lock } from "lucide-react"

const trustPoints = [
  {
    icon: UserX,
    title: "No forced accounts",
    description: "Use FollowUP without creating an account. We believe in earning your trust, not requiring it."
  },
  {
    icon: Shield,
    title: "Privacy-first approach",
    description: "Your data isn't stored, sold, or shared. Events are processed and delivered — that's it."
  },
  {
    icon: Lock,
    title: "You stay in control",
    description: "Review, edit, and approve every event before it touches your calendar. No surprises."
  }
]

export function Trust() {
  return (
    <section className="py-24 px-6 bg-muted/30">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Built on trust
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            Your personal moments deserve respect. Here's how we protect them.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {trustPoints.map((point) => (
            <div 
              key={point.title}
              className="flex flex-col items-center text-center p-8 rounded-3xl bg-card border border-border/50"
            >
              <div className="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center mb-5">
                <point.icon className="w-7 h-7 text-primary" />
              </div>
              <h3 className="text-lg font-semibold text-foreground mb-2">
                {point.title}
              </h3>
              <p className="text-muted-foreground leading-relaxed">
                {point.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
