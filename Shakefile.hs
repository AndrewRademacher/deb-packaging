#!/usr/bin/env stack
{- stack script --resolver lts-9.12
    --package shake
-}

import           Development.Shake
import           Development.Shake.Command
import           Development.Shake.FilePath
import           Development.Shake.Util
import           Prelude                    hiding (FilePath)

main :: IO ()
main = shakeArgs shakeOptions{ shakeFiles = "dist" } $ do
    want ["dist/build/hello" <.> exe]

    phony "package" $ do
        need ["dist/package/hello-1.0_amd64.deb"]

    phony "clean" $ do
        putNormal "Cleaning files in build."
        removeFilesAfter "dist" ["//*"]

    "dist/package/hello-1.0_amd64.deb" %> \out -> do
        need ["dist" </> "deb"]
        unit $ cmd "dpkg-deb --build" ["dist" </> "deb"] out

    "dist/build/hello" <.> exe %> \out -> do
        cs <- getDirectoryFiles "" ["//*.cpp"]
        let os = ["dist" </> "objects" </> c -<.> "o" | c <- cs]
        need os
        unit $ cmd "g++ -o" [out] os

    "dist/objects//*.o" %> \out -> do
        let c = dropDirectory1 $ dropDirectory1 $ out -<.> "cpp"
        let m = out -<.> "m"
        unit $ cmd "g++ -c" [c] "-o" [out] "-MMD -MF" [m]
        needMakefileDependencies m
