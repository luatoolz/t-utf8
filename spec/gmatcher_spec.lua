describe("gmatcher", function()
	local t, u, gmatcher
	setup(function()
    t = require "t"
    u = t.utf8
    gmatcher = u.gmatcher("()(.)%2")
	end)
  it("positive", function()
    local d = {3, 6, 9}
    for i in gmatcher("xuxx uu ppar r") do
      assert.equal(i, table.remove(d, 1))
    end
    assert.equal(0, #d)
  end)
end)