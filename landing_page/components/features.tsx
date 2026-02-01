"use client"

import { Camera, Brain, Edit3, Download, Shield, Heart } from "lucide-react"

const features = [
  {
    icon: Camera,
    title: "Multi-modal input",
    description: "Text, images, and voice — capture events however works best for you in the moment."
  },
  {
    icon: Brain,
    title: "Intelligent extraction",
    description: "AI understands messy, real-world input and extracts clean, structured event data."
  },
  {
    icon: Edit3,
    title: "Quick editing",
    description: "Review and adjust any field before saving. You stay in control."
  },
  {
    icon: Download,
    title: "Universal export",
    description: "One-click ICS export works with Google Calendar, Apple Calendar, and Outlook."
  },
  {
    icon: Shield,
    title: "Privacy-first",
    description: "No forced accounts, no unnecessary data storage. Your events stay yours."
  },
  {
    icon: Heart,
    title: "Peace of mind",
    description: "Stop worrying about missing important moments. Let FollowUP remember for you."
  }
]

export function Features() {
  return (
    <section id="features" className="py-24 px-6">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Designed for calm, not chaos
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            FollowUP helps you live a more balanced and present life by removing the mental burden of remembering things.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature) => (
            <div 
              key={feature.title}
              className="group p-6 rounded-2xl border border-transparent hover:border-border hover:bg-card transition-all duration-300"
            >
              <div className="w-12 h-12 rounded-xl bg-accent flex items-center justify-center mb-4 group-hover:bg-primary/10 transition-colors">
                <feature.icon className="w-6 h-6 text-primary" />
              </div>
              <h3 className="text-lg font-semibold text-foreground mb-2">
                {feature.title}
              </h3>
              <p className="text-muted-foreground leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
