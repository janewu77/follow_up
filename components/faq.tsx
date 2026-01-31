"use client"

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"

const faqs = [
  {
    question: "How does FollowUP extract event information?",
    answer:
      "FollowUP uses advanced AI to analyze your input — whether it's a photo of a flyer, a text message, or a voice note. It identifies key details like event name, date, time, location, and notes, then presents them in an editable card for your review.",
  },
  {
    question: "Which calendars can I export to?",
    answer:
      "FollowUP generates standard ICS files that work with all major calendar apps including Google Calendar, Apple Calendar, Outlook, and any other app that supports the iCalendar format. Pro users can also sync directly to their calendars.",
  },
  {
    question: "Is my data private and secure?",
    answer:
      "Absolutely. Your privacy is our priority. We don't store your photos or voice recordings after processing. Event data is encrypted and you can delete it anytime. We never sell your data to third parties.",
  },
  {
    question: "Do I need to create an account?",
    answer:
      "No! You can use FollowUP's core features without creating an account. Simply capture an event, review the details, and export to your calendar. Creating an account unlocks additional features like sync and history.",
  },
  {
    question: "What languages does FollowUP support?",
    answer:
      "FollowUP currently supports English, German, Spanish, French, and Italian. Our AI can understand dates and times in various formats common to these languages. More languages are coming soon!",
  },
  {
    question: "Can I edit the extracted information?",
    answer:
      "Yes! You always have full control. After FollowUP extracts the event details, you can edit any field — title, date, time, location, or notes — before adding it to your calendar.",
  },
  {
    question: "What happens if the AI makes a mistake?",
    answer:
      "While our AI is highly accurate, it's not perfect. That's why you always review and confirm the extracted details before exporting. You can easily correct any mistakes in the preview card.",
  },
  {
    question: "Is there a mobile app?",
    answer:
      "FollowUP works great in your mobile browser right now. Native iOS and Android apps are in development and will be available soon with additional features like notifications and widgets.",
  },
]

export function FAQ() {
  return (
    <section id="faq" className="py-24 px-6">
      <div className="max-w-3xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Frequently asked questions
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            Everything you need to know about FollowUP
          </p>
        </div>

        <Accordion type="single" collapsible className="w-full">
          {faqs.map((faq, index) => (
            <AccordionItem key={index} value={`item-${index}`} className="border-border">
              <AccordionTrigger className="text-left text-foreground hover:text-primary hover:no-underline py-6">
                {faq.question}
              </AccordionTrigger>
              <AccordionContent className="text-muted-foreground leading-relaxed pb-6">
                {faq.answer}
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  )
}
