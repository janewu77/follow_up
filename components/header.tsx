"use client"

import { Button } from "@/components/ui/button"
import Image from "next/image"

export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
      <div className="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
        <a href="#" className="flex items-center">
          <Image
            src="/images/logo.png"
            alt="FollowUP - Your smart path from input to action"
            width={140}
            height={40}
            className="h-8 w-auto"
            priority
          />
        </a>
        
        <nav className="hidden md:flex items-center gap-8">
          <a href="#how-it-works" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
            How it works
          </a>
          <a href="#features" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
            Features
          </a>
          <a href="#demo" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
            Try it
          </a>
        </nav>

        <Button size="sm" className="rounded-full px-6">
          Get Started
        </Button>
      </div>
    </header>
  )
}
