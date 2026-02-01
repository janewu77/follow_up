"use client"

import { Button } from "@/components/ui/button"
import { Check } from "lucide-react"

const plans = [
  {
    name: "Free",
    price: "0",
    description: "Perfect for trying out FollowUP",
    features: [
      "10 event captures per month",
      "Text and photo input",
      "ICS file export",
      "Basic AI extraction",
    ],
    cta: "Get Started",
    popular: false,
  },
  {
    name: "Pro",
    price: "4.99",
    description: "For individuals who want peace of mind",
    features: [
      "Unlimited event captures",
      "Text, photo, and voice input",
      "Direct calendar sync",
      "Advanced AI with smart suggestions",
      "Priority processing",
      "Email reminders",
    ],
    cta: "Start Free Trial",
    popular: true,
  },
  {
    name: "Family",
    price: "9.99",
    description: "Share calm with your loved ones",
    features: [
      "Everything in Pro",
      "Up to 5 family members",
      "Shared family calendar",
      "Delegate event creation",
      "Family activity insights",
      "Priority support",
    ],
    cta: "Start Free Trial",
    popular: false,
  },
]

export function Pricing() {
  return (
    <section id="pricing" className="py-24 px-6 bg-secondary/30">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Simple, transparent pricing
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            Start free, upgrade when you need more. No hidden fees, cancel anytime.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {plans.map((plan) => (
            <div
              key={plan.name}
              className={`relative bg-card rounded-2xl p-8 border ${
                plan.popular
                  ? "border-primary shadow-lg scale-105"
                  : "border-border"
              } transition-all duration-300 hover:shadow-md`}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2 bg-primary text-primary-foreground text-sm font-medium px-4 py-1 rounded-full">
                  Most Popular
                </div>
              )}

              <div className="mb-6">
                <h3 className="text-xl font-semibold text-foreground mb-2">
                  {plan.name}
                </h3>
                <p className="text-muted-foreground text-sm">{plan.description}</p>
              </div>

              <div className="mb-6">
                <span className="text-4xl font-bold text-foreground">
                  ${plan.price}
                </span>
                <span className="text-muted-foreground">/month</span>
              </div>

              <ul className="space-y-3 mb-8">
                {plan.features.map((feature) => (
                  <li key={feature} className="flex items-start gap-3">
                    <Check className="w-5 h-5 text-primary shrink-0 mt-0.5" />
                    <span className="text-sm text-foreground">{feature}</span>
                  </li>
                ))}
              </ul>

              <Button
                className={`w-full rounded-full ${
                  plan.popular ? "" : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                }`}
                variant={plan.popular ? "default" : "secondary"}
              >
                {plan.cta}
              </Button>
            </div>
          ))}
        </div>

        <p className="text-center text-muted-foreground text-sm mt-8">
          All plans include a 14-day free trial. No credit card required.
        </p>
      </div>
    </section>
  )
}
