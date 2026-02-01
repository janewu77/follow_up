import Image from "next/image"

export function MindfulnessTrust() {
  return (
    <section className="py-16 px-6">
      <div className="max-w-5xl mx-auto">
        <div className="relative rounded-2xl overflow-hidden">
          <Image
            src="/images/mindfulness-trust.png"
            alt="Less mental load. More presence. FollowUP quietly manages your schedule, freeing your mind for what truly matters. Features: No forced accounts, Privacy-first approach, You stay in control."
            width={1400}
            height={900}
            className="w-full h-auto"
          />
        </div>
      </div>
    </section>
  )
}
