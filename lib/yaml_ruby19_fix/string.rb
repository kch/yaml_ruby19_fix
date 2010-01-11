#!/usr/bin/env ruby1.9 -ryaml
# encoding: UTF-8

# Lets YAML know that valid UTF-8 strings are not binary data.
# This will get you a double-quoted string output, meaning all
# non-ASCII characters will be escaped in \xDD format.
# The good news is that double-quoted strings, when imported back
# by ruby 1.9's YAML::load, will be read in the default encoding
# (which should then be UTF-8), not as BINARY/ASCII-8BIT.
# For fully unescaped UTF-8 output, checkout the ya2yaml gem.
String.def_around :is_binary_data?, :utf8_dump_double_quoted do
  !(encoding == Encoding.find("UTF-8") && valid_encoding?) && is_binary_data_without_utf8_dump_double_quoted?
end

# ruby 1.8's YAML dumper tends to tag strings as !binary willy-nilly.
# This fix attempts to convert all strings back to the default
# encoding (which generally should be UTF-8, unless you're importing
# YAML data that was dumped from strings with a different encoding).
# When loading YAML, for every string that comes in with an encoding
# that is not the default, we try to force and validate it.
# Valid strings are returned with the new default encoding. Invalid
# ones are reset back to their original.
YAML::DefaultResolver.def_around :node_import, :try_default_encoding do |node|
  node_import_without_try_default_encoding(node).tap do |s|
    next unless %w( encoding force_encoding valid_encoding? ).all? { |m| s.respond_to?(m) }
    next unless s.encoding != __ENCODING__
    original_encoding = s.encoding
    s.force_encoding(__ENCODING__)
    s.force_encoding(original_encoding) unless s.valid_encoding?
  end
end
