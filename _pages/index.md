---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

nav_title: Home
title: Mountain Area Youth Soccer League
permalink: /
layout: home
header:
  overlay_image: /files/yhs-field-1.jpg
  overlay_filter: 0.4
  overlay_color: "#2d5016"
---

## Welcome to MAYSL

Mountain Area Youth Soccer League provides youth soccer for ages 3-18 in the central Sierra region of California, just south of Yosemite National Park.

{% comment %}
  Card text is built with `capture` rather than inlined into the include tag:
  Jekyll takes *quoted* include params literally (no Liquid rendering), and
  nested quotes inside them break its param parser outright. Passing the
  variable name unquoted makes Jekyll resolve it from context.
{% endcomment %}
{% assign season_start = site.data.season.dates.first_game | date: "%b %-d" %}
{% capture signup_card %}&#9917;&nbsp;<b>Season starts {{ season_start }}</b>&nbsp;&#9917;<br />
<em>Inviting players, coaches, and referees now</em>{% endcapture %}

<div class="feature-cards">
  {% include feature-card.html 
     icon="leaf" 
     title="Fall Signups!" 
     description=signup_card
     button_url="/register/"
     button_text="More Info"
     card_url="/register/" %}
</div>

<!--
<div class="feature-cards">
  {% include feature-card.html 
     icon="snowflake" 
     title="Winter Soccer for Adults" 
     description="Games will be at YHS. Jan 10 - Mar 1. Signups open until Dec 14!"
     button_url="/adult/"
     button_text="More Info"
     card_url="/adult/" %}
</div>
-->
