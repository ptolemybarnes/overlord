require './overlord'

class Foo
  include Overlord

  def bar(a, b)
    [a, b].join(', ')
  end

  def bar(a)
    a.to_s
  end

  def bar
    'wow'
  end
end

# define another class with the same method as this was previously
# causing a bug.
class Baz
  include Overlord

  def bar(a, b); end
end

describe Overlord do
  it 'matches on methods with different arities' do
    foo = Foo.new

    expect(foo.bar()).to eq 'wow'
    expect(foo.bar('hi')).to eq 'hi'
    expect(foo.bar(1, 2)).to eq '1, 2'
  end

  it 'raises undefined method when method is not defined' do
    foo = Foo.new

    expect { foo.bar(1, 2, 3) }.to raise_error(NoMethodError, 'undefined method `bar` with arity 3')
  end

  it 'works on keyword args' do
    class Thing
      include Overlord

      def bar(baz:, wow:)
        [baz, wow].join(', ')
      end
    end
    foo = Thing.new

    expect(foo.bar(baz: 'bang', wow: 'yes')).to eq 'bang, yes'
  end
end
