"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Camera, Mic, Type, Calendar, MapPin, Clock, FileText, Download, Sparkles, Check } from "lucide-react"

type InputMode = "text" | "photo" | "voice"

interface EventData {
  title: string
  date: string
  time: string
  location: string
  notes: string
}

const sampleInputs = {
  text: "Team dinner next Friday at 7pm at Olive Garden on Main Street. Don't forget to bring the birthday card for Sarah!",
  photo: "Concert poster detected: Coldplay Music of the Spheres World Tour - March 15, 2026 at 8:00 PM - Madison Square Garden, New York",
  voice: "\"Hey, I need to remember that doctor's appointment on Tuesday at 2:30 in the afternoon at the medical center downtown.\""
}

const sampleResults: Record<InputMode, EventData> = {
  text: {
    title: "Team dinner - Sarah's Birthday",
    date: "2026-02-06",
    time: "19:00",
    location: "Olive Garden, Main Street",
    notes: "Bring birthday card for Sarah"
  },
  photo: {
    title: "Coldplay - Music of the Spheres Tour",
    date: "2026-03-15",
    time: "20:00",
    location: "Madison Square Garden, New York",
    notes: "World Tour concert"
  },
  voice: {
    title: "Doctor's Appointment",
    date: "2026-02-03",
    time: "14:30",
    location: "Medical Center Downtown",
    notes: ""
  }
}

export function Demo() {
  const [mode, setMode] = useState<InputMode>("text")
  const [isProcessing, setIsProcessing] = useState(false)
  const [showResult, setShowResult] = useState(false)
  const [eventData, setEventData] = useState<EventData>(sampleResults.text)
  const [isExported, setIsExported] = useState(false)

  const handleProcess = () => {
    setIsProcessing(true)
    setShowResult(false)
    setIsExported(false)
    
    setTimeout(() => {
      setEventData(sampleResults[mode])
      setIsProcessing(false)
      setShowResult(true)
    }, 1500)
  }

  const handleExport = () => {
    setIsExported(true)
    // Create ICS file content
    const icsContent = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//FollowUP//EN
BEGIN:VEVENT
DTSTART:${eventData.date.replace(/-/g, '')}T${eventData.time.replace(':', '')}00
SUMMARY:${eventData.title}
LOCATION:${eventData.location}
DESCRIPTION:${eventData.notes}
END:VEVENT
END:VCALENDAR`
    
    const blob = new Blob([icsContent], { type: 'text/calendar' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `${eventData.title.replace(/\s+/g, '-').toLowerCase()}.ics`
    a.click()
    URL.revokeObjectURL(url)
  }

  const handleModeChange = (newMode: InputMode) => {
    setMode(newMode)
    setShowResult(false)
    setIsExported(false)
  }

  return (
    <section id="demo" className="py-24 px-6 bg-secondary/50">
      <div className="max-w-5xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-semibold text-foreground mb-4 text-balance">
            Try it yourself
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto text-pretty">
            See how FollowUP transforms messy input into clean calendar events.
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Input Card */}
          <Card className="border-border">
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-medium text-foreground">Input</CardTitle>
              <div className="flex gap-2 mt-4">
                {[
                  { id: "text" as const, icon: Type, label: "Text" },
                  { id: "photo" as const, icon: Camera, label: "Photo" },
                  { id: "voice" as const, icon: Mic, label: "Voice" }
                ].map((input) => (
                  <Button
                    key={input.id}
                    variant={mode === input.id ? "default" : "outline"}
                    size="sm"
                    className="gap-2 rounded-full"
                    onClick={() => handleModeChange(input.id)}
                  >
                    <input.icon className="w-4 h-4" />
                    {input.label}
                  </Button>
                ))}
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              {mode === "text" && (
                <Textarea 
                  placeholder="Paste or type any text containing event information..."
                  className="min-h-[140px] resize-none bg-input border-border"
                  defaultValue={sampleInputs.text}
                />
              )}
              {mode === "photo" && (
                <div className="border-2 border-dashed border-border rounded-xl p-8 text-center bg-input">
                  <Camera className="w-10 h-10 text-muted-foreground mx-auto mb-3" />
                  <p className="text-sm text-muted-foreground mb-2">
                    Drop an image or click to upload
                  </p>
                  <p className="text-xs text-muted-foreground/70">
                    Demo: {sampleInputs.photo}
                  </p>
                </div>
              )}
              {mode === "voice" && (
                <div className="border-2 border-dashed border-border rounded-xl p-8 text-center bg-input">
                  <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-3">
                    <Mic className="w-8 h-8 text-primary" />
                  </div>
                  <p className="text-sm text-muted-foreground mb-2">
                    Click to start recording
                  </p>
                  <p className="text-xs text-muted-foreground/70 italic">
                    {sampleInputs.voice}
                  </p>
                </div>
              )}
              <Button 
                className="w-full gap-2 rounded-full" 
                onClick={handleProcess}
                disabled={isProcessing}
              >
                {isProcessing ? (
                  <>
                    <Sparkles className="w-4 h-4 animate-spin" />
                    Processing...
                  </>
                ) : (
                  <>
                    <Sparkles className="w-4 h-4" />
                    Extract Event
                  </>
                )}
              </Button>
            </CardContent>
          </Card>

          {/* Output Card */}
          <Card className={`border-border transition-all duration-500 ${showResult ? 'bg-card' : 'bg-muted/30'}`}>
            <CardHeader className="pb-4">
              <CardTitle className="text-lg font-medium text-foreground">Event Preview</CardTitle>
            </CardHeader>
            <CardContent>
              {!showResult ? (
                <div className="h-[260px] flex items-center justify-center text-muted-foreground">
                  <p className="text-sm">Your extracted event will appear here</p>
                </div>
              ) : (
                <div className="space-y-4">
                  <div>
                    <label className="text-xs text-muted-foreground mb-1 block">Event Title</label>
                    <Input 
                      value={eventData.title}
                      onChange={(e) => setEventData({...eventData, title: e.target.value})}
                      className="font-medium bg-input border-border"
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                        <Calendar className="w-3 h-3" /> Date
                      </label>
                      <Input 
                        type="date"
                        value={eventData.date}
                        onChange={(e) => setEventData({...eventData, date: e.target.value})}
                        className="bg-input border-border"
                      />
                    </div>
                    <div>
                      <label className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                        <Clock className="w-3 h-3" /> Time
                      </label>
                      <Input 
                        type="time"
                        value={eventData.time}
                        onChange={(e) => setEventData({...eventData, time: e.target.value})}
                        className="bg-input border-border"
                      />
                    </div>
                  </div>
                  <div>
                    <label className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                      <MapPin className="w-3 h-3" /> Location
                    </label>
                    <Input 
                      value={eventData.location}
                      onChange={(e) => setEventData({...eventData, location: e.target.value})}
                      className="bg-input border-border"
                    />
                  </div>
                  <div>
                    <label className="text-xs text-muted-foreground mb-1 flex items-center gap-1">
                      <FileText className="w-3 h-3" /> Notes
                    </label>
                    <Input 
                      value={eventData.notes}
                      onChange={(e) => setEventData({...eventData, notes: e.target.value})}
                      placeholder="Optional notes"
                      className="bg-input border-border"
                    />
                  </div>
                  <Button 
                    className="w-full gap-2 rounded-full" 
                    variant={isExported ? "outline" : "default"}
                    onClick={handleExport}
                  >
                    {isExported ? (
                      <>
                        <Check className="w-4 h-4" />
                        Downloaded!
                      </>
                    ) : (
                      <>
                        <Download className="w-4 h-4" />
                        Add to Calendar
                      </>
                    )}
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </section>
  )
}
