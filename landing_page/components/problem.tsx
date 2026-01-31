"use client"

import { ImageIcon, MessageSquare, FileText, Mic } from "lucide-react"

const painPoints = [
  {
    icon: ImageIcon,
    label: "Screenshots of event posters"
  },
  {
    icon: MessageSquare,
    label: "Messages with dates and times"
  },
  {
    icon: FileText,
    label: "Flyers and invitations"
  },
  {
    icon: Mic,
    label: "Voice notes to yourself"
  }
]

export function Problem() {
  return (
    <section className="py-24 px-6 bg-muted/30">
      <div className="max-w-4xl mx-auto text-center">
        <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-6 text-balance">
          Life events come at you fast
        </h2>
        <p className="text-lg text-muted-foreground mb-12 max-w-2xl mx-auto text-pretty">
          Important dates arrive as screenshots, posters, messages, or quick voice notes. 
          Manually adding them to your calendar? Stressful, slow, and easy to forget.
        </p>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-12">
          {painPoints.map((point) => (
            <div 
              key={point.label}
              className="flex flex-col items-center gap-3 p-6 rounded-2xl bg-card border border-border/50"
            >
              <div className="w-12 h-12 rounded-xl bg-accent flex items-center justify-center">
                <point.icon className="w-6 h-6 text-primary" />
              </div>
              <span className="text-sm text-muted-foreground text-center leading-snug">
                {point.label}
              </span>
            </div>
          ))}
        </div>

        <p className="text-xl text-foreground font-medium text-balance">
          You deserve a simpler way.
        </p>
      </div>
    </section>
  )
}
