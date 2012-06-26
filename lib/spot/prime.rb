require "levenshtein"
require_relative "clean"

module Spot
  class Prime
    @@ignore = YAML.load(File.read("#{File.dirname(__FILE__)}/ignore.yml"))

    #
    # @results Array<Object>
    # @compare String
    # @options Hash
    #
    def initialize(results, compare, options = {})
      @options = {
        popularity: 7,
        exclude: 2,
        limit: 0.7,
        offset: 10
      }.merge(options)

      @results, @compare = results, compare
    end

    #
    # @return Array<Object>
    #
    def results
      @results.sort_by(&:popularity).map do |result|
        match = clean(result.to_s).split(/\s+/).sort
        raw = clean(@compare).split(/\s+/).sort

        if raw.length < match.length
          diff = (match - raw)
          res = diff.length.to_f / match.length
        else
          diff = (raw - match)
          res = diff.length.to_f / raw.length
        end

        if diff.length > 1 and not match.map{ |m| diff.include?(m) }.all?
          res =+ diff.map do |value|
            match.map { |m| Levenshtein.normalized_distance(value, m) }.inject(:+)
          end.inject(:+) / @options[:offset]
        end
        
        [res - result.popularity / @options[:popularity], result]
      end.reject do |_, result|
        Spot::Prime.ignore?(result.to_s, @compare)
      end.sort_by do |distance, _|
        distance
      end.map(&:last)
    end

    #
    # @value String To be cleaned
    # @return String A cleaned string
    #
    def clean(value)
      Spot::Clean.new(value).process
    end

    #
    # @this String
    # @compare String
    # @return Boolean
    #
    def self.ignore?(this, compare = nil)
      @@ignore.
        reject{ |value| compare.to_s.match(/#{value}/i) }.
        map{ |value| this.match(/#{value}/i) }.any?
    end
  end
end