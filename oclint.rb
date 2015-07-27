class Oclint < Formula
  desc "A clang-based static analyser for C, C++, and Objective C"
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
    ENV.append("LDFLAGS", '-lc++abi')

    (buildpath/"oclint-xcodebuild").install resource("oclint-xcodebuild")
    bin.install "oclint-xcodebuild/oclint-xcodebuild"

    chdir "oclint-scripts" do
      system "sh", "./makeWithExternClang", "#{HOMEBREW_PREFIX}/opt/llvm"
    end
    system "cp", "-a", "./build/oclint-release/", "#{prefix}/"
  end
end
