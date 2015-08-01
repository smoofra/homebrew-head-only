class Oclint < Formula
  desc "A clang-based static analyser for C, C++, objC"
  homepage "http://oclint.org"

  ### oclint-0.8.1 doesn't build, I think because of some clang API changes.

  head do
    url "https://github.com/oclint/oclint.git"

    resource "oclint-xcodebuild" do
      url "https://github.com/oclint/oclint-xcodebuild.git"
    end
  end

  depends_on "cmake" => :build
  depends_on "llvm" => "with-clang"

  def install
    # Homebrew llvm libc++.dylib doesn't correctly reexport libc++abi
    ENV.append("LDFLAGS", "-lc++abi")

    (buildpath/"oclint-xcodebuild").install resource("oclint-xcodebuild")
    bin.install "oclint-xcodebuild/oclint-xcodebuild"

    chdir "oclint-scripts" do
      system "sh", "./makeWithExternClang", "#{HOMEBREW_PREFIX}/opt/llvm"
    end
    cp_r Dir["./build/oclint-release/*"], prefix
  end

  test do
    (testpath/"foo.c").write(<<-END.undent)
      int foo(int zaphod, int beeblebrox) {
          return zaphod;
      }
      END
    (testpath/"compile_commands.json").write(<<-END.undent)
      [{"directory": "#{Pathname.pwd}",
        "command":  "clang -c foo.c -o foo.o",
        "file":     "foo.c"}]
      END
    assert_match /unused.*parameter.*beeblebrox/i,
                 shell_output("#{bin}/oclint foo.c", 0)
  end
end
