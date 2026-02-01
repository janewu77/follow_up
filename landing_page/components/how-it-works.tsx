import Image from "next/image"

export function HowItWorks() {
  return (
    <section id="how-it-works" className="py-24 px-6 bg-secondary/30">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Your smart path from input to action
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            No more manual entry. No more forgotten events. Just capture and go.
          </p>
        </div>

        <div className="relative rounded-2xl overflow-hidden">
          <Image
            src="/images/process-flow.png"
            alt="FollowUP 4-step process: 1. Capture - Snap, type, or speak. 2. Understand - AI processes your input. 3. Confirm - Review the suggestion. 4. Done - It's in your calendar."
            width={1400}
            height={800}
            className="w-full h-auto"
            priority
          />
        </div>

        <div className="text-center mt-8">
          <p className="text-xl md:text-2xl font-semibold text-primary text-balance">
            From Capture to Calendar in under 30 seconds.
          </p>
          <p className="text-muted-foreground mt-2">
            Simple, secure, and seamless.
          </p>
        </div>
      </div>
    </section>
  )
}
