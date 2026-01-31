import Image from "next/image"

export function Footer() {
  return (
    <footer className="py-16 px-6 border-t border-border">
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row items-center justify-between gap-8">
          <a href="#" className="flex items-center">
            <Image
              src="/images/logo.png"
              alt="FollowUP - Your smart path from input to action"
              width={140}
              height={40}
              className="h-8 w-auto"
            />
          </a>

          <p className="text-center text-muted-foreground text-sm max-w-md text-pretty">
            Turn moments from real life into calendar events, so you can stop remembering and start living.
          </p>

          <div className="flex items-center gap-6">
            <a href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
              Privacy
            </a>
            <a href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
              Terms
            </a>
            <a href="#" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
              Contact
            </a>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-border text-center">
          <p className="text-xs text-muted-foreground">
            © 2026 FollowUP. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}
