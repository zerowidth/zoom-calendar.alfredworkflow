#!/usr/bin/env ruby

require_relative "alfred"

ZOOM_REGEX = %r((?<url>https://(\w+\.)?zoom.us/./(?<meeting_id>\d+(\?pwd=\w+)?)))m
HREF_REGEX = %r(<a .*href="(?<url>[^"]+)".*>(?<title>[^<]+)<\/a>)m # a href
URL_REGEX = %r((?<url>https?://(?!(\w+\.)?zoom\.us)[^\b]+)\b)m # url, but not zoom
NUM_REGEX = %r((?<number>\d{3}-?\d{3}-?\d{3}))

icon = Alfred::Icon.new(path: "icon.png")

def error(message)
  Alfred.display Alfred::Item.new(
    title: message,
    icon: Alfred::Icon.new(path: "octicons-alert.png")
  )
  exit
end

# -ea exclude all-day events
# -n only display events from now on, not the start of the day
# -b '* ' define bullet character
# -nnr " " notes separator to use instead of newline
# -ps "|\\n|" sets field separator to just a newline
# -po title,datetime,location,url,notes sets field order
# -iep title,datetime,location,url,notes sets what fields to retrieve
# eventsToday+2 shows "now plus two days"
output = `/usr/local/bin/icalbuddy -ea -n -b '* ' -nnr " " -ps "|\\n|" -po title,datetime,location,url,notes -iep title,datetime,location,url,notes eventsToday+2 2>&1`
error(output) if $? != 0

events = output.split(/^\* /)[1..-1] || []
entries = events.map do |event|
  title, time, details = event.split("\n", 3)
  time.capitalize!
  next unless match = details.match(ZOOM_REGEX)
  if (link = details.match(HREF_REGEX))
    link_url = link[:url]
    link_title = link[:title]
  elsif (link = details.match URL_REGEX)
    link_url = link_title = link[:url]
  end

  meeting_id = match[:meeting_id].sub("?pwd","&pwd")
  url = "zoommtg://zoom.us/join?confno=#{meeting_id}"

  mods = nil
  if link && !link_url.include?(".zoom.us")
    time << " (⌘ to also open #{link_title})"
    cmd = Alfred::Modifier.new \
      valid: true,
      subtitle: "Join meeting and open #{link_title} (#{link_url})",
      arg: url,
      variables: { link: link_url }
    alt = Alfred::Modifier.new \
      valid: true,
      subtitle: "Open #{link_title} (#{link_url})",
      arg: "",
      variables: { link: link_url }
    mods = Alfred::Modifiers.new cmd: cmd, alt: alt
  end

  Alfred::Item.new \
    title: title,
    subtitle: time,
    arg: url,
    text: Alfred::Text.new(copy: match[:url]),
    mods: mods,
    icon: icon
end

paste = `pbpaste`
if match = paste.match(ZOOM_REGEX)
  entries.unshift Alfred::Item.new(
    title: "clipboard: #{match[:url]}",
    arg: "zoommtg://zoom.us/join?confno=#{match[:meeting_id]}",
    icon: icon
  )
elsif match = paste.match(NUM_REGEX)
  meeting_id = match[:number].gsub("-","")
  entries.unshift Alfred::Item.new(
    title: "clipboard: #{match[:number]}",
    arg: "zoommtg://zoom.us/join?confno=#{meeting_id}",
    icon: icon
  )
end

if entries.compact.empty?
  entries << Alfred::Item.new(
    title: "You have no zoom meetings coming up.",
    icon: icon,
    valid: false
  )
end

Alfred.display entries.compact.first(9)
