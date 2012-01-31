#!/usr/bin/env ruby
#
# hartog/20120131: Heidi, the CI mistress

require 'sinatra'
require './lib/routes.rb'

# modular setup with all the freebees of a non modular setup.
include Routes
