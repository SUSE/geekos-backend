# `ap` is muscle memory from awesome_print. Ruby's own `pp` prints the
# same structures, so keep the short name and drop the gem.
module Kernel
  alias ap pp
  private :ap
end
