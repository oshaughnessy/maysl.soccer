----
# Welcome to Jekyll!
#
# This config file is meant for settings that affect your whole blog, values
# which you are expected to set up once and rarely edit after that. If you find
# yourself editing this file very often, consider using Jekyll's data files
# feature for the data you need to update frequently.
#
# For technical reasons, this file is *NOT* reloaded automatically when you use
# 'bundle exec jekyll serve'. If you change this file, please restart the server process.
#
# If you need help with YAML syntax, here are some quick references for you: 
# https://learn-the-web.algonquindesign.ca/topics/markdown-yaml-cheat-sheet/#yaml
# https://learnxinyminutes.com/docs/yaml/
#
# Site settings
# These are used to personalize your new site. If you look in the HTML files,
# you will see them accessed via {{ site.title }}, {{ site.email }}, and so on.
# You can create any custom variable you would like, and they will be accessible
# in the templates via {{ site.myvariable }}.

title: MAYSL
email: shaug-maysl@wumpus.org
description: >- # this means to ignore newlines until "baseurl:"
  Mountain Area Youth Soccer League
author: O'Shaughnessy Evans #  Default is your site title.
baseurl: "" # the subpath of your site, e.g. /blog
url: "https://maysl.soccer" # the base hostname & protocol for your site, e.g. http://example.com
twitter_username: ohshaughnessy
github_username:  oshaughnessy

# Build settings
#theme: minima
#theme: jekyll-theme-tactile
#theme: jekyll-theme-persephone
#remote_theme: pages-themes/midnight@v0.2.0
remote_theme: erlzhang/jekyll-theme-persephone
markdown: kramdown
plugins:
  - jekyll-feed
  - jekyll-remote-theme

# Exclude from processing.
# The following items will not be processed, by default.
# Any item listed under the `exclude:` key here will be automatically added to
# the internal "default list".
#
# Excluded items can be processed by explicitly listing the directories or
# their entries' file path in the `include:` list.
#
# exclude:
#   - .sass-cache/
#   - .jekyll-cache/
#   - gemfiles/
#   - Gemfile
#   - Gemfile.lock
#   - node_modules/
#   - vendor/bundle/
#   - vendor/cache/
#   - vendor/gems/
#   - vendor/ruby/


# # Your social accounts.
# social:
#   github: github_username
#   twitter: twitter_username
#   facebook: facebook_username
#   instagram: instagram_username
#   linkedin: linkedin_username
#   weibo: weibo_username

# # Theme Settings

# # Your site's logo. Will be shown on the left top of your page.
# logo: /img/logo.svg
# # If the images of our blog are stored in an external cloud. You can use the jekyll-img-prefix plugin and set your images' base URL here.
# img_prefix: https://your-img-cdn.com
# # The RSS link of your blog.
# rss: "/feed.xml"

# # The followings are settings for displays of your blog.
theme_setting:
#   # The slides count in the slides layout. Default is 4.
#   slides_count: 5
#   # The â back URL on the top of your post page. Default is your site's home page.
#   blog_page: "blog/index.md"
#   # The URL on your name on the bottom of your post and page. Default is your site's home page.
  about_page: "about.md"
#   #  The URL of the menu icon(which has three black lines). Will be shown on the slides/book/chapter layouts It won't be shown if blank.
#   archive_page: "archive.md"
#   # The nav links on the top right of home/page/post/blog layout. You can set a local page(by setting a layout's path) or and external link ( both title and url are required) here.
  nav_pages:
    - about.md
    - contact.md
#    - title: "External Link Title"
#      url: "https://your-external-link.com"
#   # Every default value in the following settings is false. You can set them globally here or separately in a single post/page/chapter.
#   code: true # Code highlight.
#   math: true # Mathjax
#   mermaid: true # Mermaid
#   #  Locales of this theme.
#   lang:
#     category_all: All # The first tag in the categories bar on the blog layout page. By clicking it all of your posts will be shown. Default is 'All'.
#     blog_title: Blog # The text of â back url on the top of the post layout.  Default is 'Home'.
#     # The locales of the comment controls.
#     comment:
#       user: "æµç§°"
#       email: "é®ç®±"
#       url: "é¾æ¥"
#       message: "è¯´ç¹ä»ä¹å§..."
#       reply: "åå¤"

# head_code: |
#   <!-- Extra codes in the head of your site pages. You can add your Google Analysis codes here! -->

# # The settings of comments.
# comment:
#   # You should set it to enable comment
#   enabled: true
#   # Your comment provider
#   provider: disqus # static/disqus
#   # If provider == disqus
#   disqus:
#     name: website_name
#   # Or provider == static
#   static:
#     # Your static comment url.
#     postUrl:  https://api.staticman.net/v2/connect/GITHUB-USERNAME/GITHUB-REPOSITORY
# # The settings of local smileys used in static comments. The jekyll-smiley plugin is required.
# smiley:
#   enabled: true
#   dir: img/smileys
