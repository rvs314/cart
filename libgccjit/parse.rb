# frozen_string_literal: true

RST_FN_PREFIX = '.. function::'
FN_NAME_PREFIX = 'gcc_jit'

PREAMBLE = <<~PREAMBLE
  (define-module (cart libgccjit bindings)
    #:use-module (shorthand ffi)
    #:use-module (system foreign)
    #:use-module (system foreign-library))
  
  (define jit (dynamic-link "/usr/lib/gcc/x86_64-linux-gnu/11/libgccjit.so"))
PREAMBLE

# Reads the code declarations from a RST file
# @returns [Array]
# @param filename [String] prefix [String]
def read_decls(filename, prefix = RST_FN_PREFIX)
  q = File.open(filename, &:read)
  q.gsub!("\\\n", '')

  q = q.lines
  q.each(&:strip!)
  q.filter! { |l| l.start_with? prefix }
  q.each { |l| l.delete_prefix! prefix }

  q
end

# Turns a C function declaration into an
# array of tokens
# @returns [Array]
# @param fn_dec [String]
def tokenize_decl(fn_dec)
  %w(\) * \( ,).each do |c|
    fn_dec.gsub!(c, " #{c} ")
  end

  fn_dec.split
end

# Parses an array of type tokens into a single
# type for use in jit.scm
# @returns [String]
# @param type [Array]
def parse_type(type)
  type = %w[ptr] if type.last == '*'
  type = %w[int] if type.first == 'enum'
  return nil if type.empty?
  raise NotImplementedError, "Cannot parse type #{type}" unless type.length == 1

  type.first
end

# Renames a function into a more appropriate declaration
# @return [String]
# @param fn_name [String]
def rename_fn(fn_name)
  fn_name = fn_name.clone

  fn_name.delete_prefix! FN_NAME_PREFIX
  fn_name.delete_prefix! '_'
  fn_name.gsub! '_', '-'
  fn_name.gsub! '-as-', '->'

  fn_name
end

# Parses a declaration as a token list into a SEXPR for use
# in jit.scm
# @return [String]
# @param decl [String]
def parse_decl(decl)
  (*return_type, fn_name), (_, *args, _) = (tokenize_decl decl).slice_before('(').to_a

  # @type arg [Array]
  args = args.slice_before(',').to_a

  args.map! do |arg|
    arg.delete ','
    *arg_type, _arg_name = arg
    parse_type arg_type
  end

  args.compact!

  return_type = parse_type return_type

  "(#{rename_fn fn_name} (#{return_type} #{fn_name} (#{args.join ' '})))"
end

# Parses an RST file into an array of SEXPR for using in jit.scm
# reads input from the file namned +fn_name+
# @returns [Array]
# @param fn_name [String]
def parse_decls(fn_name)
  read_decls(fn_name).map { parse_decl _1 }
end

def main
  puts PREAMBLE
  ARGV.each do |arg|
    puts "\n;; #{arg}"
    puts parse_decls(arg).join("\n")
  end
end

main if $PROGRAM_NAME == __FILE__
