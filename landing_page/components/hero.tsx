"use client"

import { Button } from "@/components/ui/button"
import { ArrowRight, Camera, Mic, Type } from "lucide-react"
import Image from "next/image"

export function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0 z-0">
        <Image
          src="/images/hero-bg.png"
          alt="Person using FollowUP app in a sunny outdoor cafe"
          fill
          className="object-cover"
          priority
        />
        <div className="absolute inset-0 bg-gradient-to-r from-background/95 via-background/70 to-transparent" />
      </div>

      {/* Content */}
      <div className="relative z-10 max-w-7xl mx-auto px-6 py-32 w-full">
        <div className="max-w-xl">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-card/80 backdrop-blur-sm text-foreground text-sm mb-8 border border-border/50">
            <span className="w-2 h-2 rounded-full bg-primary animate-pulse" />
            Your personal AI calendar assistant
          </div>
          
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-semibold text-foreground leading-tight tracking-tight mb-6 text-balance">
            Never miss a moment
            <br />
            <span className="text-primary">that matters.</span>
          </h1>
          
          <p className="text-lg md:text-xl text-muted-foreground max-w-lg mb-10 leading-relaxed text-pretty">
            FollowUP turns photos, text, or voice into calendar events — so you can stop stressing and start living.
          </p>

          <div className="flex flex-col sm:flex-row items-start gap-4 mb-12">
            <Button size="lg" className="rounded-full px-8 gap-2" asChild>
              <a href="#demo">
                Try the Demo
                <ArrowRight className="w-4 h-4" />
              </a>
            </Button>
            <Button variant="outline" size="lg" className="rounded-full px-8 bg-card/60 backdrop-blur-sm border-border/50 hover:bg-card/80" asChild>
              <a href="#how-it-works">See how it works</a>
            </Button>
          </div>

          <div className="flex items-center gap-6 text-foreground">
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-full bg-card/80 backdrop-blur-sm flex items-center justify-center border border-border/50">
                <Camera className="w-5 h-5 text-primary" />
              </div>
              <span className="text-sm font-medium">Photo</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-full bg-card/80 backdrop-blur-sm flex items-center justify-center border border-border/50">
                <Type className="w-5 h-5 text-primary" />
              </div>
              <span className="text-sm font-medium">Text</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded-full bg-card/80 backdrop-blur-sm flex items-center justify-center border border-border/50">
                <Mic className="w-5 h-5 text-primary" />
              </div>
              <span className="text-sm font-medium">Voice</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}
