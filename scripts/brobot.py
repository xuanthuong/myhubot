#  -*- coding: utf-8 -*-
"""
Practice on creating a bot
reference: https://apps.worldwritable.com/tutorials/chatbot/

Date: Jun 14, 2017
@author: Liza Daly
@praticer: Thuong Tran
"""


import logging
from textblob import TextBlob
import random


# logging.basicConfig()
# logger = logging.getLogger()
# logger.setLevel(logging.DEBUG)

# start: example-hello.py
# Sentences we'll respond with if the user greeted us
GREETING_KEYWORDS = ('hello', 'hi', 'greetings', 'sup', "what's up")
GREETING_RESPONSES = ["'sup bro", "hey", "*nods*", "hey how are you doing?"]


def check_for_greeting(sentence):
  """If any of the words in the user's input was a greeting, return a greeting response"""
  for word in sentence.words:
    if word.lower() in GREETING_KEYWORDS:
      return random.choice(GREETING_RESPONSES)

# start: example-none.py
# Sentences we'll respond with if we have no idea what the user just said
NONE_RESPONSES = [
  "uh whatever",
  "meet me at the foosball table, bro?",
  "code hard bro",
  "want to bro down and crush code?",
  "I'd like to add you to my professional network on LinkedIn",
  "Today is beautiful, let enjoy, bro"
]
#end


def broback(sentence):
  """Main program loop: select a response for the input sentence and return it"""
  # logger.info("Broback: respond to %s", sentence)
  return respond(sentence)


def preprocess_text(sentence):
  """Handle some weird edge cases in parsing, like 'i' needing to be capitalized
  to be correctly identified as a pronoun"""
  cleaned = []
  words = sentence.split(' ')
  for w in words:
    if w == 'i':
      w = 'I'
    if w == "i'm":
      w = "I'm"
    cleaned.append(w)
  # logger.info('preprocess_text: Cleaned sentence: %s' % cleaned)
  return ' '.join(cleaned)


def find_pronoun(sent):
  """Given a sentence, find a preferred pronoun to respond with. Returns None if no candidate
  pronoun is found in the input"""
  pronoun = None
  for word, part_of_speech in sent.pos_tags:
    # Disambiguate pronouns
    if part_of_speech == 'PRP' and word.lower() == 'you':
      pronoun = 'I'
    elif part_of_speech == 'PRP' and word == 'I':
      # If the user mentioned themselves, then they will definitely be the pronoun
      pronoun = 'You'
  return pronoun


def find_noun(sent):
  """Given a sentence, find the best candidate noun."""
  noun = None
  for w, pos in sent.pos_tags:
    if pos == 'NN':
      noun = w
      break
  return noun


def find_adjective(sent):
  """Given a sentence, find the best candidate adjective."""
  adj = None
  for w, pos in sent.pos_tags:
    if pos == 'JJ':
      adj = w
      break
  return adj


def find_verb(sent):
  """Pick a candidate verb for the sentence."""
  verb = None
  pos = None
  for w, p in sent.pos_tags:
    if p.startswith('VB'):
      verb = w
      pos = p
      break
  return verb, pos


def check_for_comment_about_bot(pronoun, noun, adjective):
  """Check if the user's input was about the bot itselt, in which case try to fashion a response
  that feels right based on their input. Returns the new best sentence, or None."""
  resp = None
  if pronoun == 'I' and (noun or adjective):
    if noun:
      if random.choice((True, False)):
        resp = random.choice(SELF_VERBS_WITH_NOUN_CAPS_PLURAL).format(**{'noun': noun.pluralize().capitalize()})
      else:
        resp = random.choice(SELF_VERBS_WITH_NOUN_LOWER).format(**{'noun': noun})
    else:
        resp = random.choice(SELF_VERBS_WITH_ADJECTIVE).format(**{'adjective': adjective})
  return resp
# Template for responses that include a direct noun which is indefinite/uncountable
SELF_VERBS_WITH_NOUN_CAPS_PLURAL = [
    "My last startup totally crushed the {noun} vertical",
    "Were you aware I was a serial entrepreneur in the {noun} sector?",
    "My startup is AI Chatbot for {noun}",
    "I really consider myself an expert on {noun}",
]

SELF_VERBS_WITH_NOUN_LOWER = [
    "Yeah but I know a lot about {noun}",
    "My bros always ask me about {noun}",
]

SELF_VERBS_WITH_ADJECTIVE = [
    "I'm personally building the {adjective} Economy",
    "I consider myself to be a {adjective}preneur",
]
# end

def find_candidate_parts_of_speech(parsed):
  """Given a parsed input, find the best pronoun, direct noun, adjective, and verb to match their input.
  Return a tuple of pronoun, noun, adjective, verb any of which may be None if there wass no good match"""
  pronoun = None
  noun = None
  adjective = None
  verb = None
  for sent in parsed.sentences:
    pronoun = find_pronoun(sent)
    noun = find_noun(sent)
    adjective = find_adjective(sent)
    verb = find_verb(sent)
  # logger.info("Pronoun=%s, noun=%s, adjective=%s, verb=%s", pronoun, noun, adjective, verb)
  return pronoun, noun, adjective, verb

# start: example-respond.py
def respond(sentence):
  """Parse the user's inbound sentence and find candidate terms that make up a best-fit response"""
  cleaned = preprocess_text(sentence)
  parsed = TextBlob(cleaned)
  # logger.info('Respond: Parsed results: %s' % parsed)

  """Loop through all the sentences, if more than one. This will help extract the most relevant
  response text even across multiple sentences (for example if there was no obvious direct noun
  in one sentence"""
  pronoun, noun, adjective, verb = find_candidate_parts_of_speech(parsed)

  """If we said something about the bot and used some kind of direct noun, construct the
  sentence around that, discarding the other candidates"""
  resp = check_for_comment_about_bot(pronoun, noun, adjective)
  # logger.info('Respond: comment about bot?: %s' % resp)

  # If we just greeted the bot, we'll use a return greeting
  if not resp:
    resp = check_for_greeting(parsed)
  if not resp:
    resp = random.choice(NONE_RESPONSES)
  # logger.info("Returning phrase '%s'" % resp)
  # filter_response(resp)
  return resp


if __name__ == '__main__':
  import sys
  # Usage:
  # python brobot.py "I am a reseacher"
  if (len(sys.argv) > 0):
    saying = sys.argv[1]
  else:
    saying = "Hi, How are you?"
  print (broback(saying))