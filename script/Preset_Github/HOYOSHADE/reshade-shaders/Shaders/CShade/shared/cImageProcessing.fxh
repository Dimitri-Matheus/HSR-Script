#include "cGraphics.fxh"

#if !defined(CIMAGEPROCESSING_FXH)
    #define CIMAGEPROCESSING_FXH

    /*
        [Convolutions - Blur]
    */

    /*
        Linear Gaussian blur
        ---
        https://www.rastergrid.com/blog/2010/09/efficient-Gaussian-blur-with-linear-sampling/
    */

    float GetGaussianWeight(float SampleIndex, float Sigma)
    {
        const float Pi = acos(-1.0);
        float Output = rsqrt(2.0 * Pi * (Sigma * Sigma));
        return Output * exp(-(SampleIndex * SampleIndex) / (2.0 * Sigma * Sigma));
    }

    float GetGaussianOffset(float SampleIndex, float Sigma, out float LinearWeight)
    {
        float Offset1 = SampleIndex;
        float Offset2 = SampleIndex + 1.0;
        float Weight1 = GetGaussianWeight(Offset1, Sigma);
        float Weight2 = GetGaussianWeight(Offset2, Sigma);
        LinearWeight = Weight1 + Weight2;
        return ((Offset1 * Weight1) + (Offset2 * Weight2)) / LinearWeight;
    }

    float4 GetPixelBlur(VS2PS_Quad Input, sampler2D SampleSource, bool Horizontal)
    {
        // Initialize variables
        const int KernelSize = 10;
        const float4 HShift = float4(-1.0, 0.0, 1.0, 0.0);
        const float4 VShift = float4(0.0, -1.0, 0.0, 1.0);

        float4 OutputColor = 0.0;
        float4 PSize = fwidth(Input.Tex0).xyxy;

        const float Offsets[KernelSize] =
        {
            0.0, 1.490652, 3.4781995, 5.465774, 7.45339,
            9.441065, 11.42881, 13.416645, 15.404578, 17.392626,
        };

        const float Weights[KernelSize] =
        {
            0.06299088, 0.122137636, 0.10790718, 0.08633988, 0.062565096,
            0.04105926, 0.024403222, 0.013135255, 0.006402994, 0.002826693
        };

        // Sample and weight center first to get even number sides
        float TotalWeight = Weights[0];
        OutputColor = tex2D(SampleSource, Input.Tex0 + (Offsets[0] * PSize.xy)) * Weights[0];

        // Sample neighboring pixels
        for(int i = 1; i < KernelSize; i++)
        {
            const float4 Offset = (Horizontal) ? Offsets[i] * HShift: Offsets[i] * VShift;
            float4 Tex = Input.Tex0.xyxy + (Offset * PSize);
            OutputColor += tex2D(SampleSource, Tex.xy) * Weights[i];
            OutputColor += tex2D(SampleSource, Tex.zw) * Weights[i];
            TotalWeight += (Weights[i] * 2.0);
        }

        // Normalize intensity to prevent altered output
        return OutputColor / TotalWeight;
    }

    /*
        Wojciech Sterna's shadow sampling code as a screen-space convolution (http://maxest.gct-game.net/content/chss.pdf)
        ---
        Vogel disk sampling: http://blog.marmakoide.org/?p=1
        Rotated noise sampling: http://www.iryoku.com/next-generation-post-processing-in-call-of-duty-advanced-warfare (slide 123)
    */

    float2 SampleVogel(int Index, int SamplesCount)
    {
        const float Pi = acos(-1.0);
        const float GoldenAngle = Pi * (3.0 - sqrt(5.0));
        float Radius = sqrt(float(Index) + 0.5) * rsqrt(float(SamplesCount));
        float Theta = float(Index) * GoldenAngle;

        float2 SinCosTheta = 0.0;
        SinCosTheta[0] = sin(Theta);
        SinCosTheta[1] = cos(Theta);
        return Radius * SinCosTheta;
    }

    float4 Filter3x3(sampler2D SampleSource, float2 Tex, bool DownSample)
    {
        const float3 Weights = float3(1.0, 2.0, 4.0) / 16.0;
        float2 PixelSize = fwidth(Tex);
        PixelSize = (DownSample) ? PixelSize * 0.5 : PixelSize;

        float4 STex[3] =
        {
            Tex.xyyy + (float4(-2.0, 2.0, 0.0, -2.0) * abs(PixelSize.xyyy)),
            Tex.xyyy + (float4(0.0, 2.0, 0.0, -2.0) * abs(PixelSize.xyyy)),
            Tex.xyyy + (float4(2.0, 2.0, 0.0, -2.0) * abs(PixelSize.xyyy))
        };

        float4 OutputColor = 0.0;
        OutputColor += (tex2D(SampleSource, STex[0].xy) * Weights[0]);
        OutputColor += (tex2D(SampleSource, STex[1].xy) * Weights[1]);
        OutputColor += (tex2D(SampleSource, STex[2].xy) * Weights[0]);
        OutputColor += (tex2D(SampleSource, STex[0].xz) * Weights[1]);
        OutputColor += (tex2D(SampleSource, STex[1].xz) * Weights[2]);
        OutputColor += (tex2D(SampleSource, STex[2].xz) * Weights[1]);
        OutputColor += (tex2D(SampleSource, STex[0].xw) * Weights[0]);
        OutputColor += (tex2D(SampleSource, STex[1].xw) * Weights[1]);
        OutputColor += (tex2D(SampleSource, STex[2].xw) * Weights[0]);
        return OutputColor;
    }

    /*
        [Convolutions - Edge Detection]
    */

    /*
        Linear filtered Sobel filter
    */

    struct VS2PS_Sobel
    {
        float4 HPos : SV_POSITION;
        float4 Tex0 : TEXCOORD0;
    };

    VS2PS_Sobel GetVertexSobel(APP2VS Input, float2 PixelSize)
    {
        VS2PS_Quad FSQuad = VS_Quad(Input);

        VS2PS_Sobel Output;
        Output.HPos = FSQuad.HPos;
        Output.Tex0 = FSQuad.Tex0.xyxy + (float4(-0.5, -0.5, 0.5, 0.5) * PixelSize.xyxy);
        return Output;
    }

    float2 GetPixelSobel(VS2PS_Sobel Input, sampler2D SampleSource)
    {
        float2 OutputColor0 = 0.0;
        float A = tex2D(SampleSource, Input.Tex0.xw).r * 4.0; // <-0.5, +0.5>
        float B = tex2D(SampleSource, Input.Tex0.zw).r * 4.0; // <+0.5, +0.5>
        float C = tex2D(SampleSource, Input.Tex0.xy).r * 4.0; // <-0.5, -0.5>
        float D = tex2D(SampleSource, Input.Tex0.zy).r * 4.0; // <+0.5, -0.5>
        OutputColor0.x = ((B + D) - (A + C)) / 4.0;
        OutputColor0.y = ((A + B) - (C + D)) / 4.0;
        return OutputColor0;
    }

    /*
        [Noise Generation]
    */

    /*
        https://www.shadertoy.com/view/4djSRW

        Copyright (c) 2014 David Hoskins

        Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    */

    float GetHash1(float2 P, float Bias)
    {
        float3 P3 = frac(P.xyx * 0.1031);
        P3 += dot(P3, P3.yzx + 33.33);
        return frac(((P3.x + P3.y) * P3.z) + Bias);
    }

    float2 GetHash2(float2 P, float2 Bias)
    {
        float3 P3 = frac(P.xyx * float3(0.1031, 0.1030, 0.0973));
        P3 += dot(P3, P3.yzx + 33.33);
        return frac(((P3.xx + P3.yz) * P3.zy) + Bias);
    }

    float3 GetHash3(float2 P, float3 Bias)
    {
        float3 P3 = frac(P.xyx * float3(0.1031, 0.1030, 0.0973));
        P3 += dot(P3, P3.yxz + 33.33);
        return frac(((P3.xxy + P3.yzz) * P3.zyx) + Bias);
    }

    /*
        Interleaved Gradient Noise Dithering
        ---
        http://www.iryoku.com/downloads/Next-Generation-Post-Processing-in-Call-of-Duty-Advanced-Warfare-v18.pptx
    */

    float GetIGNoise(float2 Position)
    {
        return frac(52.9829189 * frac(dot(Position, float2(0.06711056, 0.00583715))));
    }

    float3 GetDither(float2 Position)
    {
        return GetIGNoise(Position) / 255.0;
    }

    /*
        GetGradientNoise(): https://iquilezles.org/articles/gradientnoise/
        GetQuintic(): https://iquilezles.org/articles/texture/

        The MIT License (MIT)

        Copyright (c) 2017 Inigo Quilez

        Permission is hereby granted, free of charge, to any person obtaining a copy of this
        software and associated documentation files (the "Software"), to deal in the Software
        without restriction, including without limitation the rights to use, copy, modify,
        merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
        permit persons to whom the Software is furnished to do so, subject to the following
        conditions:

        The above copyright notice and this permission notice shall be included in all copies
        or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
        INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
        PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
        HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
        CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
        OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    */

    float2 GetQuintic(float2 X)
    {
        return X * X * X * (X * (X * 6.0 - 15.0) + 10.0);
    }

    float GetValueNoise(float2 Tex, float Bias)
    {
        float2 I = floor(Tex);
        float2 F = frac(Tex);
        float A = GetHash1(I + float2(0.0, 0.0), Bias);
        float B = GetHash1(I + float2(1.0, 0.0), Bias);
        float C = GetHash1(I + float2(0.0, 1.0), Bias);
        float D = GetHash1(I + float2(1.0, 1.0), Bias);
        float2 UV = GetQuintic(F);
        return lerp(lerp(A, B, UV.x), lerp(C, D, UV.x), UV.y);
    }

    float GetGradient(float2 I, float2 F, float2 O, float Bias)
    {
        // Get constants
        const float TwoPi = acos(-1.0) * 2.0;

        // Calculate random hash rotation
        float Hash = GetHash1(I + O, Bias) * TwoPi;
        float2 HashSinCos = float2(sin(Hash), cos(Hash));

        // Calculate final dot-product
        return dot(HashSinCos, F - O);
    }

    float GetGradientNoise(float2 Tex, float Bias)
    {
        float2 I = floor(Tex);
        float2 F = frac(Tex);
        float A = GetGradient(I, F, float2(0.0, 0.0), Bias);
        float B = GetGradient(I, F, float2(1.0, 0.0), Bias);
        float C = GetGradient(I, F, float2(0.0, 1.0), Bias);
        float D = GetGradient(I, F, float2(1.0, 1.0), Bias);
        float2 UV = GetQuintic(F);
        float Noise = lerp(lerp(A, B, UV.x), lerp(C, D, UV.x), UV.y);
        return saturate((Noise * 0.5) + 0.5);
    }

    /*
        [Color Processing]
    */

    float3 GetSumChromaticity(float3 Color, int Method)
    {
        float Sum = 0.0;
        float White = 0.0;

        switch(Method)
        {
            case 0: // Length
                Sum = length(Color);
                White = 1.0 / sqrt(3.0);
                break;
            case 1: // Dot3 Average
                Sum = dot(Color, 1.0 / 3.0);
                White = 1.0;
                break;
            case 2: // Dot3 Sum
                Sum = dot(Color, 1.0);
                White = 1.0 / 3.0;
                break;
            case 3: // Max
                Sum = max(max(Color.r, Color.g), Color.b);
                White = 1.0;
                break;
        }

        float3 Chromaticity = (Sum == 0.0) ? White : Color / Sum;
        return Chromaticity;
    }

    /*
        Ratio-based chromaticity
    */

    float2 GetRatioRG(float3 Color)
    {
        float2 Ratio = (Color.z == 0.0) ? 1.0 : Color.xy / Color.zz;
        // x / (x + 1.0) normalizes to [0, 1] range
        return Ratio / (Ratio + 1.0);
    }

    /*
        https://www.microsoft.com/en-us/research/publication/ycocg-r-a-color-space-with-rgb-reversibility-and-low-dynamic-range/
        ---
        YCoCg-R: A Color Space with RGB Reversibility and Low Dynamic Range
        Henrique S. Malvar, Gary Sullivan
        MSR-TR-2003-103 | July 2003
        ---
        Technical contribution to the H.264 Video Coding Standard. Joint Video Team (JVT) of ISO/IEC MPEG & ITU-T VCEG (ISO/IEC JTC1/SC29/WG11 and ITU-T SG16 Q.6) Document JVT-I014r3.
    */

    float2 GetCoCg(float3 Color)
    {
        float2 CoCg = 0.0;
        float2x3 MatCoCg = float2x3
        (
            float3(1.0, 0.0, -1.0),
            float3(-0.5, 1.0, -0.5)
        );

        CoCg.x = dot(Color, MatCoCg[0]);
        CoCg.y = dot(Color, MatCoCg[1]);

        return (CoCg * 0.5) + 0.5;
    }

    /*
        RGB to CrCb
        ---
        https://docs.opencv.org/4.7.0/de/d25/imgproc_color_conversions.html
    */

    float2 GetCrCb(float3 Color)
    {
        float Y = dot(Color, float3(0.299, 0.587, 0.114));
        return ((Color.br - Y) * float2(0.564, 0.713)) + 0.5;
    }

    /*
        RGB to saturation value.
        ---
        Golland, Polina, and Alfred M. Bruckstein. "Motion from color."
        Computer Vision and Image Understanding 68, no. 3 (1997): 346-362.
        ---
        http://www.cs.technion.ac.il/users/wwwb/cgi-bin/tr-get.cgi/1995/CIS/CIS9513.pdf
    */

    float SaturateRGB(float3 Color)
    {
        // Calculate min and max RGB
        float MinColor = min(min(Color.r, Color.g), Color.b);
        float MaxColor = max(max(Color.r, Color.g), Color.b);

        // Calculate normalized RGB
        float SatRGB = (MaxColor - MinColor) / MaxColor;
        SatRGB = (MaxColor == 0.0) ? 0.0 : SatRGB;

        return SatRGB;
    }

    /*
        Color-space conversion
        ---
        https://github.com/colour-science/colour
        ---
        Copyright 2013 Colour Developers

        Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

        3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE
    */

    float3 GetHSVfromRGB(float3 Color)
    {
        float MinRGB = min(min(Color.r, Color.g), Color.b);
        float MaxRGB = max(max(Color.r, Color.g), Color.b);
        float DeltaRGB = MaxRGB - MinRGB;

        // Calculate hue
        float3 Hue = (Color.gbr - Color.brg) / DeltaRGB;
        Hue = (Hue * (60.0 / 360.0)) + (float3(0.0, 120.0, 240.0) / 360.0);
        float OutputHue = 0.0;
        OutputHue = (MaxRGB == Color.r) ? Hue.r : OutputHue;
        OutputHue = (MaxRGB == Color.g) ? Hue.g : OutputHue;
        OutputHue = (MaxRGB == Color.b) ? Hue.b : OutputHue;

        float3 Output = 0.0;
        Output.x = (DeltaRGB == 0.0) ? 0.0 : OutputHue;
        Output.y = (DeltaRGB == 0.0) ? 0.0 : DeltaRGB / MaxRGB;
        Output.z = MaxRGB;
        return Output;
    }

    float3 GetHSLfromRGB(float3 Color)
    {
        float MinRGB = min(min(Color.r, Color.g), Color.b);
        float MaxRGB = max(max(Color.r, Color.g), Color.b);
        float AddRGB = MaxRGB + MinRGB;
        float DeltaRGB = MaxRGB - MinRGB;

        float Lightness = AddRGB / 2.0;
        float Saturation = (Lightness < 0.5) ?  DeltaRGB / AddRGB : DeltaRGB / (2.0 - AddRGB);

        // Calculate hue
        float3 Hue = (Color.gbr - Color.brg) / DeltaRGB;
        Hue = (Hue * (60.0 / 360.0)) + (float3(0.0, 120.0, 240.0) / 360.0);
        float OutputHue = 0.0;
        OutputHue = (MaxRGB == Color.r) ? Hue.r : OutputHue;
        OutputHue = (MaxRGB == Color.g) ? Hue.g : OutputHue;
        OutputHue = (MaxRGB == Color.b) ? Hue.b : OutputHue;

        float3 Output = 0.0;
        Output.x = (DeltaRGB == 0.0) ? 0.0 : OutputHue;
        Output.y = (DeltaRGB == 0.0) ? 0.0 : Saturation;
        Output.z = Lightness;
        return Output;
    }

    /*
        This code is based on the algorithm described in the following paper:
        Author(s): Joost van de Weijer, T. Gevers
        Title: "Robust optical flow from photometric invariants"
        Year: 2004
        DOI: 10.1109/ICIP.2004.1421433
    */

    float2 GetSphericalRG(float3 Color)
    {
        const float HalfPi = 1.0 / acos(0.0);
        const float2 White = acos(rsqrt(float2(2.0, 3.0)));

        // Precalculate (x*x + y*y)^0.5 and (x*x + y*y + z*z)^0.5
        float L1 = length(Color.rg);
        float L2 = length(Color.rgb);

        float2 Angles = 0.0;
        Angles[0] = (L1 == 0.0) ? 1.0 / sqrt(2.0) : Color.g / L1;
        Angles[1] = (L2 == 0.0) ? 1.0 / sqrt(3.0) : L1 / L2;

        return saturate(asin(abs(Angles)) * HalfPi);
    }

    float3 GetHSIfromRGB(float3 Color)
    {
        float3 O = Color.rrr;
        O += (Color.ggg * float3(-1.0, 1.0, 1.0));
        O += (Color.bbb * float3(0.0, -2.0, 1.0));
        O *= rsqrt(float3(2.0, 6.0, 3.0));

        float H = atan(O.x/O.y) / acos(0.0);
        H = (H * 0.5) + 0.5; // We also scale to [0,1] range
        float S = length(O.xy);
        float I = O.z;

        return float3(H, S, I);
    }
#endif
