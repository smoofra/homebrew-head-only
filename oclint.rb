class Oclint < Formula
  desc "A clang-based static analyser for C, C++, objC"
  homepage "http://oclint.org"
  ### doesn't build, I think because of some clang API change.x
  # url "http://archives.oclint.org/releases/0.8/oclint-0.8.1-src.tar.gz"
  # sha256 "fb6dab9ac619bacfea42e56469147cfc40e680642cedf352b87986c0bf1f7510"

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
    mktemp do
      File.open("foo.c", "w") do |f|
        f.write(<<-END.undent)
        int foo(int zaphod, int beeblebrox) {
            return zaphod;
        }
        END
      end
      compile_commands = [
        "directory" => Pathname.pwd.to_s,
        "command" => "clang -c foo.c -o foo.o",
        "file" => "foo.c"
      ]
      require "json"
      File.open("compile_commands.json", "w") do |f|
        f.write(JSON.generate(compile_commands))
      end
      assert_match /unused.*parameter.*beeblebrox/i,
                   shell_output("#{bin}/oclint foo.c", 0)
    end
  end
end
