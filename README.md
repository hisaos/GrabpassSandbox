## GrabpassSandbox
GrabpassでPhotoshop風のレイヤー重ね合わせによるブレンド効果をUnityで実装してみた  
Spriteどうしの重ね合わせでスクリーンやハードライトなどの効果を得られます
## 実装してるブレンドモード
- 焼き込み(ColorBurn)
- 覆い焼き(ColorDodge)
- 差(Difference)
- 除外(Exclusion)
- 露出(Exposure)
- ハードライト(Hardlight)
- 色相(Hue)
- 乗算(Multiply)
- ノイズ(Noise)
- オーバーレイ(Overlay)
- スクリーン(Screen)
- ソフトライト(Softlight)

Shaders配下にこれらのブレンドモードを計算する.shaderが並んでいます  
Materials配下にある.matにこれらのシェーダを適用したマテリアルが並んでます  
シェーダー名は各ブレンドモードの英語名に接頭辞"Grab"を付けたもの、マテリアル名はシェーダー名と同じです  
スプライトに.matを適用してブレンドモードを指定した表示できます
## サンプル
### Scenes/RGBbox
R,G,Bの正方形を重ね合わせて表示
### Scenes/ShaderAnimation
重ねているほうのスプライトに適用するシェーダーをUnityのアニメーションで切り替えるループ
## ライセンス
MIT License
## 参考にしたもの
[ブレンドモード詳説 - osakana.factory](https://ofo.jp/osakana/cgtips/blendmode.phtml)  
[Blend Modes in Unity - Elringus](https://elringus.me/blend-modes-in-unity/)  
[Unity の Shader (ShaderLab) 知識ざっくりメモ](http://izmiz.hateblo.jp/entry/2014/02/23/223405)  
[Unityのシェーダーについて自分なりにまとめてみた](http://sssslide.com/speakerdeck.com/esprogram/unityfalsesiedanituitezi-fen-narinimatometemita)
