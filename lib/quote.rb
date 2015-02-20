# -*- coding: utf-8 -*-
require 'cinch'

require './lib/bot_helper'
require './lib/database'

class Quote
  include Cinch::Plugin

  listen_to :channel

  def listen(m)
    return if (m.message =~ /\A!q/).nil?

    dataset = Database.connection[:quotes]

    if quote_mode(m.message) == :add
      text = m.message.split(' add ').last

      return if dataset.where(text: text).count > 0

      dataset.insert(text: text)

      m.reply("#{m.user.nick}, Quote added")
    elsif quote_mode(m.message) == :named_random
      search = m.message.split('!q ').last
      text   = dataset.select(:text).where{ Sequel.like(:text, "%#{search}%")}.
               order { rand{} }.first

      m.reply(text[:text]) if text
    else
      text = dataset.select(:text).order { rand{} }.first

      m.reply(text[:text]) if text
    end
  end

  def quote_mode(message)
    if message =~ /\A!q add (<[^>]+>) .+/
      :add
    elsif message =~ /\A!q \w+/
      :named_random
    else
      :random
    end
  end
end