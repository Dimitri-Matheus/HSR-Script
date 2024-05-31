/*******************************************************************************
    Author: Vortigern

    License:
    https://github.com/ampas/aces-dev

    Academy Color Encoding System (ACES) software and tools are provided by the
    Academy under the following terms and conditions: A worldwide, royalty-free,
    non-exclusive right to copy, modify, create derivatives, and use, in source and
    binary forms, is hereby granted, subject to acceptance of this license.

    Copyright 2015 Academy of Motion Picture Arts and Sciences (A.M.P.A.S.).
    Portions contributed by others as indicated. All rights reserved.

    Performance of any of the aforementioned acts indicates acceptance to be bound
    by the following terms and conditions:

    * Copies of source code, in whole or in part, must retain the above copyright
    notice, this list of conditions and the Disclaimer of Warranty.

    * Use in binary form must retain the above copyright notice, this list of
    conditions and the Disclaimer of Warranty in the documentation and/or other
    materials provided with the distribution.

    * Nothing in this license shall be deemed to grant any rights to trademarks,
    copyrights, patents, trade secrets or any other intellectual property of
    A.M.P.A.S. or any contributors, except as expressly stated herein.

    * Neither the name "A.M.P.A.S." nor the name of any other contributors to this
    software may be used to endorse or promote products derivative of or based on
    this software without express prior written permission of A.M.P.A.S. or the
    contributors, as appropriate.

    This license shall be construed pursuant to the laws of the State of
    California, and any disputes related thereto shall be subject to the
    jurisdiction of the courts therein.

    Disclaimer of Warranty: THIS SOFTWARE IS PROVIDED BY A.M.P.A.S. AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
    THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND
    NON-INFRINGEMENT ARE DISCLAIMED. IN NO EVENT SHALL A.M.P.A.S., OR ANY
    CONTRIBUTORS OR DISTRIBUTORS, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, RESITUTIONARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
    OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    WITHOUT LIMITING THE GENERALITY OF THE FOREGOING, THE ACADEMY SPECIFICALLY
    DISCLAIMS ANY REPRESENTATIONS OR WARRANTIES WHATSOEVER RELATED TO PATENT OR
    OTHER INTELLECTUAL PROPERTY RIGHTS IN THE ACADEMY COLOR ENCODING SYSTEM, OR
    APPLICATIONS THEREOF, HELD BY PARTIES OTHER THAN A.M.P.A.S.,WHETHER DISCLOSED OR
    UNDISCLOSED.
*******************************************************************************

#pragma once
#include "Includes/vort_Defs.fxh"

/*******************************************************************************
    Globals
*******************************************************************************/

// Mid gray for both ACEScc and ACEScct
#define ACES_LOG_MID_GRAY 0.4135884

/*******************************************************************************
    Functions
*******************************************************************************/

static const float3x3 AP1_2_XYZ_MAT = float3x3(
     0.6624541811, 0.1340042065, 0.1561876870,
     0.2722287168, 0.6740817658, 0.0536895174,
    -0.0055746495, 0.0040607335, 1.0103391003
);

static const float3x3 XYZ_2_AP1_MAT = float3x3(
     1.6410233797, -0.3248032942, -0.2364246952,
    -0.6636628587,  1.6153315917,  0.0167563477,
     0.0117218943, -0.0082844420,  0.9883948585
);

//mul(AP0_2_XYZ_MAT, XYZ_2_AP1_MAT); 
static const float3x3 AP0_2_AP1_MAT = float3x3(
     1.4514393161, -0.2365107469, -0.2149285693,
    -0.0765537734,  1.1762296998, -0.0996759264,
     0.0083161484, -0.0060324498,  0.9977163014
);

//mul(AP1_2_XYZ_MAT, XYZ_2_AP0_MAT);
static const float3x3 AP1_2_AP0_MAT = float3x3(
     0.6954522414,  0.1406786965,  0.1638690622,
     0.0447945634,  0.8596711185,  0.0955343182,
    -0.0055258826,  0.0040252103,  1.0015006723
);

static const float3 AP1_RGB2Y = float3(
    0.2722287168, //AP1_2_XYZ_MAT[0][1],
    0.6740817658, //AP1_2_XYZ_MAT[1][1],
    0.0536895174 //AP1_2_XYZ_MAT[2][1]
);

static const float3x3 XYZ_2_sRGB_MAT = float3x3(
     3.2409699419, -1.5373831776, -0.4986107603,
    -0.9692436363,  1.8759675015,  0.0415550574,
     0.0556300797, -0.2039769589,  1.0569715142
);

static const float3x3 sRGB_2_XYZ_MAT = float3x3(
    0.4124564, 0.3575761, 0.1804375,
    0.2126729, 0.7151522, 0.0721750,
    0.0193339, 0.1191920, 0.9503041
);

// Bradford chromatic adaptation
static const float3x3 D65_2_D60_CAT = float3x3(
     1.01303,    0.00610531, -0.014971,
     0.00769823, 0.998165,   -0.00503203,
    -0.00284131, 0.00468516,  0.924507
);

static const float3x3 D60_2_D65_CAT = float3x3(
     0.987224,   -0.00611327, 0.0159533,
    -0.00759836,  1.00186,    0.00533002,
     0.00307257, -0.00509595, 1.08168
);

float rgb_2_saturation(float3 rgb)
{
    float minrgb = min(min(rgb.r, rgb.g), rgb.b);
    float maxrgb = max(max(rgb.r, rgb.g), rgb.b);
    return (max(maxrgb, 1e-10) - max(minrgb, 1e-10)) / max(maxrgb, 1e-2);
}

float glow_fwd(float ycIn, float glowGainIn, float glowMid)
{
   float glowGainOut;

   if (ycIn <= 2./3. * glowMid) {
       glowGainOut = glowGainIn;
   } else if (ycIn >= 2 * glowMid) {
       glowGainOut = 0;
   } else {
       glowGainOut = glowGainIn * (glowMid / ycIn - 0.5);
   }

   return glowGainOut;
}

float glow_inv(float ycOut, float glowGainIn, float glowMid)
{
    float glowGainOut;

    if (ycOut <= ((1 + glowGainIn) * 2./3. * glowMid)) {
        glowGainOut = -glowGainIn / (1 + glowGainIn);
    } else if (ycOut >= (2. * glowMid)) {
        glowGainOut = 0.;
    } else {
        glowGainOut = glowGainIn * (glowMid / ycOut - 1./2.) / (glowGainIn / 2. - 1.);
    }

    return glowGainOut;
}


float sigmoid_shaper(float x)
{
    // Sigmoid function in the range 0 to 1 spanning -2 to +2.

    float t = max(1 - abs(0.5 * x), 0);
    float y = 1 + sign(x) * (1 - t*t);
    return 0.5 * y;
}


// ------- Red modifier functions
float cubic_basis_shaper
(
  float x,
  float w   // full base width of the shaper function (in degrees)
)
{
    //return Square(smoothstep(0, 1, 1 - abs(2 * x/w)));

    float M[16] =
    {
        -1./6,  3./6, -3./6,  1./6 ,
         3./6, -6./6,  3./6,  0./6 ,
        -3./6,  0./6,  3./6,  0./6 ,
         1./6,  4./6,  1./6,  0./6
    };

    float knots[5] = { -0.5 * w, -0.25 * w, 0, 0.25 * w, 0.5 * w };

    float y = 0;
    if ((x > knots[0]) && (x < knots[4]))
    {
        float knot_coord = (x - knots[0]) * 4.0 / w;
        int j = knot_coord;
        float t = knot_coord - j;

        float monomials[4] = { t*t*t, t*t, t, 1.0 };

        // (if/else structure required for compatibility with CTL < v1.5.)
        if (j == 3) {
            y = monomials[0] * M[0*4+0] + monomials[1] * M[1*4+0] +
                monomials[2] * M[2*4+0] + monomials[3] * M[3*4+0];
        } else if (j == 2) {
            y = monomials[0] * M[0*4+1] + monomials[1] * M[1*4+1] +
                monomials[2] * M[2*4+1] + monomials[3] * M[3*4+1];
        } else if (j == 1) {
            y = monomials[0] * M[0*4+2] + monomials[1] * M[1*4+2] +
                monomials[2] * M[2*4+2] + monomials[3] * M[3*4+2];
        } else if (j == 0) {
            y = monomials[0] * M[0*4+3] + monomials[1] * M[1*4+3] +
                monomials[2] * M[2*4+3] + monomials[3] * M[3*4+3];
        } else {
            y = 0.0;
        }
    }

    return y * 1.5;
}

float center_hue(float hue, float centerH)
{
    float hueCentered = hue - centerH;

    if (hueCentered < -180.)
        hueCentered += 360;
    else if (hueCentered > 180.)
        hueCentered -= 360;

    return hueCentered;
}


// Textbook monomial to basis-function conversion matrix.
static const float3x3 M = float3x3(
     0.5, -1.0, 0.5,
    -1.0,  1.0, 0.5,
     0.5,  0.0, 0.0
);

float segmented_spline_c5_fwd(float x)
{
    // RRT_PARAMS
    static const float coefsLow[6] = { -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 };
    static const float coefsHigh[6] = { -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 };
    static const float2 minPoint = float2(0.18*exp2(-15.0), 0.0001);
    static const float2 midPoint = float2(0.18, 4.8);
    static const float2 maxPoint = float2(0.18*exp2(18.0),  10000.);
    static const float slopeLow = 0.0;
    static const float slopeHigh = 0.0;

    static const int N_KNOTS_LOW = 4;
    static const int N_KNOTS_HIGH = 4;

    // Check for negatives or zero before taking the log. If negative or zero,
    // set to ACESMIN.1
    float xCheck = x <= 0 ? exp2(-14.0) : x;

    float logx = log10(xCheck);
    float logy;

    if (logx <= log10(minPoint.x))
    {
        logy = logx * slopeLow + (log10(minPoint.y) - slopeLow * log10(minPoint.x));
    }
    else if ((logx > log10(minPoint.x)) && (logx < log10(midPoint.x)))
    {
        float knot_coord = (N_KNOTS_LOW-1) * (logx-log10(minPoint.x))/(log10(midPoint.x)-log10(minPoint.x));
        int j = knot_coord;
        float t = knot_coord - j;

        float3 cf = float3(coefsLow[ j], coefsLow[ j + 1], coefsLow[ j + 2]);
        float3 monomials = float3(t * t, t, 1.0);

        logy = dot(monomials, mul(cf, M));
    }
    else if ((logx >= log10(midPoint.x)) && (logx < log10(maxPoint.x)))
    {
        float knot_coord = (N_KNOTS_HIGH-1) * (logx-log10(midPoint.x))/(log10(maxPoint.x)-log10(midPoint.x));
        int j = knot_coord;
        float t = knot_coord - j;

        float3 cf = float3(coefsHigh[ j], coefsHigh[ j + 1], coefsHigh[ j + 2]);
        float3 monomials = float3(t * t, t, 1.0);

        logy = dot(monomials, mul(cf, M));
    }
    else
    { //if (logIn >= log10(maxPoint.x)) {
        logy = logx * slopeHigh + (log10(maxPoint.y) - slopeHigh * log10(maxPoint.x));
    }

    return pow(10, logy);
}

float segmented_spline_c5_rev(float y)
{
    // RRT_PARAMS
    static const float coefsLow[6] = { -4.0000000000, -4.0000000000, -3.1573765773, -0.4852499958, 1.8477324706, 1.8477324706 };
    static const float coefsHigh[6] = { -0.7185482425, 2.0810307172, 3.6681241237, 4.0000000000, 4.0000000000, 4.0000000000 };
    static const float2 minPoint = float2(0.18*exp2(-15.0), 0.0001);
    static const float2 midPoint = float2(0.18, 4.8);
    static const float2 maxPoint = float2(0.18*exp2(18.0),  10000.);
    static const float slopeLow = 0.0;
    static const float slopeHigh = 0.0;

    static const int N_KNOTS_LOW = 4;
    static const int N_KNOTS_HIGH = 4;

    static const float KNOT_INC_LOW = (log10(midPoint.x) - log10(minPoint.x)) / (N_KNOTS_LOW - 1.);
    static const float KNOT_INC_HIGH = (log10(maxPoint.x) - log10(midPoint.x)) / (N_KNOTS_HIGH - 1.);

    int i;

    // KNOT_Y is luminance of the spline at each knot
    float KNOT_Y_LOW[N_KNOTS_LOW];
    for (i = 0; i < N_KNOTS_LOW; i = i+1)
    {
        KNOT_Y_LOW[i] = (coefsLow[i] + coefsLow[i+1]) / 2.;
    };

    float KNOT_Y_HIGH[N_KNOTS_HIGH];
    for (i = 0; i < N_KNOTS_HIGH; i = i+1)
    {
        KNOT_Y_HIGH[i] = (coefsHigh[i] + coefsHigh[i+1]) / 2.;
    };

    float logy = log10(max(y,1e-10));

    float logx;
    if (logy <= log10(minPoint.y))
    {
        logx = log10(minPoint.x);
    }
    else if ((logy > log10(minPoint.y)) && (logy <= log10(midPoint.y)))
    {
        uint j;
        float3 cf;
        if (logy > KNOT_Y_LOW[ 0] && logy <= KNOT_Y_LOW[ 1]) {
            cf.x = coefsLow[0];  cf.y = coefsLow[1];  cf.z = coefsLow[2];  j = 0;
        } else if (logy > KNOT_Y_LOW[ 1] && logy <= KNOT_Y_LOW[ 2]) {
            cf.x = coefsLow[1];  cf.y = coefsLow[2];  cf.z = coefsLow[3];  j = 1;
        } else if (logy > KNOT_Y_LOW[ 2] && logy <= KNOT_Y_LOW[ 3]) {
            cf.x = coefsLow[2];  cf.y = coefsLow[3];  cf.z = coefsLow[4];  j = 2;
        }

        const float3 tmp = mul(cf, M);

        float a = tmp[ 0];
        float b = tmp[ 1];
        float c = tmp[ 2];
        c = c - logy;

        const float d = sqrt(b * b - 4. * a * c);

        const float t = (2. * c) / (-d - b);

        logx = log10(minPoint.x) + (t + j) * KNOT_INC_LOW;
    }
    else if ((logy > log10(midPoint.y)) && (logy < log10(maxPoint.y)))
    {
        uint j;
        float3 cf;
        if (logy > KNOT_Y_HIGH[ 0] && logy <= KNOT_Y_HIGH[ 1]) {
            cf.x = coefsHigh[0];  cf.y = coefsHigh[1];  cf.z = coefsHigh[2];  j = 0;
        } else if (logy > KNOT_Y_HIGH[ 1] && logy <= KNOT_Y_HIGH[ 2]) {
            cf.x = coefsHigh[1];  cf.y = coefsHigh[2];  cf.z = coefsHigh[3];  j = 1;
        } else if (logy > KNOT_Y_HIGH[ 2] && logy <= KNOT_Y_HIGH[ 3]) {
            cf.x = coefsHigh[2];  cf.y = coefsHigh[3];  cf.z = coefsHigh[4];  j = 2;
        }

        const float3 tmp = mul(cf, M);

        float a = tmp[ 0];
        float b = tmp[ 1];
        float c = tmp[ 2];
        c = c - logy;

        const float d = sqrt(b * b - 4. * a * c);

        const float t = (2. * c) / (-d - b);

        logx = log10(midPoint.x) + (t + j) * KNOT_INC_HIGH;
    }
    else
    { //if (logy >= log10(maxPoint.y)) {
        logx = log10(maxPoint.x);
    }

    return pow(10, logx);
}

float segmented_spline_c9_fwd(float x)
{
    static const float coefsLow[10] = { -1.6989700043, -1.6989700043, -1.4779000000, -1.2291000000, -0.8648000000, -0.4480000000, 0.0051800000, 0.4511080334, 0.9113744414, 0.9113744414};
    static const float coefsHigh[10] = { 0.5154386965, 0.8470437783, 1.1358000000, 1.3802000000, 1.5197000000, 1.5985000000, 1.6467000000, 1.6746091357, 1.6878733390, 1.6878733390 };
    static const float2 minPoint = float2(segmented_spline_c5_fwd(0.18*exp2(-6.5)), 0.02);
    static const float2 midPoint = float2(segmented_spline_c5_fwd(0.18), 4.8);
    static const float2 maxPoint = float2(segmented_spline_c5_fwd(0.18*exp2(6.5)), 48.0);
    static const float slopeLow = 0.0;
    static const float slopeHigh = 0.04;

    static const int N_KNOTS_LOW = 8;
    static const int N_KNOTS_HIGH = 8;

    // Check for negatives or zero before taking the log. If negative or zero,
    // set to OCESMIN.
    float xCheck = x <= 0 ? 1e-4 : x;

    float logx = log10(xCheck);
    float logy;

    if (logx <= log10(minPoint.x))
    {
        logy = logx * slopeLow + (log10(minPoint.y) - slopeLow * log10(minPoint.x));
    }
    else if ((logx > log10(minPoint.x)) && (logx < log10(midPoint.x)))
    {
        float knot_coord = (N_KNOTS_LOW - 1) * (logx - log10(minPoint.x)) / (log10(midPoint.x) - log10(minPoint.x));
        int j = knot_coord;
        float t = knot_coord - j;

        float3 cf = float3(coefsLow[j], coefsLow[j + 1], coefsLow[j + 2]);
        float3 monomials = float3(t * t, t, 1.0);

        logy = dot(monomials, mul(cf, M));
    }
    else if ((logx >= log10(midPoint.x)) && (logx < log10(maxPoint.x)))
    {
        float knot_coord = (N_KNOTS_HIGH - 1) * (logx - log10(midPoint.x)) / (log10(maxPoint.x) - log10(midPoint.x));
        int j = knot_coord;
        float t = knot_coord - j;

        float3 cf = float3(coefsHigh[j], coefsHigh[j + 1], coefsHigh[j + 2]);
        float3 monomials = float3(t * t, t, 1.0);

        logy = dot(monomials, mul(cf, M));
    }
    else//if (logIn >= log10(maxPoint.x))
    {
        logy = logx * slopeHigh + (log10(maxPoint.y) - slopeHigh * log10(maxPoint.x));
    }

    return pow(10, logy);
}

float segmented_spline_c9_rev(float y)
{
    static const float coefsLow[10] = { -1.6989700043, -1.6989700043, -1.4779000000, -1.2291000000, -0.8648000000, -0.4480000000, 0.0051800000, 0.4511080334, 0.9113744414, 0.9113744414};
    static const float coefsHigh[10] = { 0.5154386965, 0.8470437783, 1.1358000000, 1.3802000000, 1.5197000000, 1.5985000000, 1.6467000000, 1.6746091357, 1.6878733390, 1.6878733390 };
    static const float2 minPoint = float2(segmented_spline_c5_fwd(0.18*exp2(-6.5)), 0.02);
    static const float2 midPoint = float2(segmented_spline_c5_fwd(0.18), 4.8);
    static const float2 maxPoint = float2(segmented_spline_c5_fwd(0.18*exp2(6.5)), 48.0);
    static const float slopeLow = 0.0;
    static const float slopeHigh = 0.04;

    static const int N_KNOTS_LOW = 8;
    static const int N_KNOTS_HIGH = 8;

    static const float KNOT_INC_LOW = (log10(midPoint.x) - log10(minPoint.x)) / (N_KNOTS_LOW - 1.);
    static const float KNOT_INC_HIGH = (log10(maxPoint.x) - log10(midPoint.x)) / (N_KNOTS_HIGH - 1.);

    int i;

    // KNOT_Y is luminance of the spline at each knot
    float KNOT_Y_LOW[ N_KNOTS_LOW];
    for (i = 0; i < N_KNOTS_LOW; i = i+1) {
        KNOT_Y_LOW[ i] = (coefsLow[i] + coefsLow[i+1]) / 2.;
    };

    float KNOT_Y_HIGH[ N_KNOTS_HIGH];
    for (i = 0; i < N_KNOTS_HIGH; i = i+1) {
        KNOT_Y_HIGH[ i] = (coefsHigh[i] + coefsHigh[i+1]) / 2.;
    };

    float logy = log10(max(y, 1e-10));

    float logx;
    if (logy <= log10(minPoint.y)) {
        logx = log10(minPoint.x);
    } else if ((logy > log10(minPoint.y)) && (logy <= log10(midPoint.y))) {
        uint j;
        float3 cf;
        if (logy > KNOT_Y_LOW[ 0] && logy <= KNOT_Y_LOW[ 1]) {
            cf.x = coefsLow[0];  cf.y = coefsLow[1];  cf.z = coefsLow[2];  j = 0;
        } else if (logy > KNOT_Y_LOW[ 1] && logy <= KNOT_Y_LOW[ 2]) {
            cf.x = coefsLow[1];  cf.y = coefsLow[2];  cf.z = coefsLow[3];  j = 1;
        } else if (logy > KNOT_Y_LOW[ 2] && logy <= KNOT_Y_LOW[ 3]) {
            cf.x = coefsLow[2];  cf.y = coefsLow[3];  cf.z = coefsLow[4];  j = 2;
        } else if (logy > KNOT_Y_LOW[ 3] && logy <= KNOT_Y_LOW[ 4]) {
            cf.x = coefsLow[3];  cf.y = coefsLow[4];  cf.z = coefsLow[5];  j = 3;
        } else if (logy > KNOT_Y_LOW[ 4] && logy <= KNOT_Y_LOW[ 5]) {
            cf.x = coefsLow[4];  cf.y = coefsLow[5];  cf.z = coefsLow[6];  j = 4;
        } else if (logy > KNOT_Y_LOW[ 5] && logy <= KNOT_Y_LOW[ 6]) {
            cf.x = coefsLow[5];  cf.y = coefsLow[6];  cf.z = coefsLow[7];  j = 5;
        } else if (logy > KNOT_Y_LOW[ 6] && logy <= KNOT_Y_LOW[ 7]) {
            cf.x = coefsLow[6];  cf.y = coefsLow[7];  cf.z = coefsLow[8];  j = 6;
        }

        const float3 tmp = mul(cf, M);

        float a = tmp[ 0];
        float b = tmp[ 1];
        float c = tmp[ 2];
        c = c - logy;

        const float d = sqrt(b * b - 4. * a * c);

        const float t = (2. * c) / (-d - b);

        logx = log10(minPoint.x) + (t + j) * KNOT_INC_LOW;
    } else if ((logy > log10(midPoint.y)) && (logy < log10(maxPoint.y))) {
        uint j;
        float3 cf;
        if (logy > KNOT_Y_HIGH[ 0] && logy <= KNOT_Y_HIGH[ 1]) {
            cf.x = coefsHigh[0];  cf.y = coefsHigh[1];  cf.z = coefsHigh[2];  j = 0;
        } else if (logy > KNOT_Y_HIGH[ 1] && logy <= KNOT_Y_HIGH[ 2]) {
            cf.x = coefsHigh[1];  cf.y = coefsHigh[2];  cf.z = coefsHigh[3];  j = 1;
        } else if (logy > KNOT_Y_HIGH[ 2] && logy <= KNOT_Y_HIGH[ 3]) {
            cf.x = coefsHigh[2];  cf.y = coefsHigh[3];  cf.z = coefsHigh[4];  j = 2;
        } else if (logy > KNOT_Y_HIGH[ 3] && logy <= KNOT_Y_HIGH[ 4]) {
            cf.x = coefsHigh[3];  cf.y = coefsHigh[4];  cf.z = coefsHigh[5];  j = 3;
        } else if (logy > KNOT_Y_HIGH[ 4] && logy <= KNOT_Y_HIGH[ 5]) {
            cf.x = coefsHigh[4];  cf.y = coefsHigh[5];  cf.z = coefsHigh[6];  j = 4;
        } else if (logy > KNOT_Y_HIGH[ 5] && logy <= KNOT_Y_HIGH[ 6]) {
            cf.x = coefsHigh[5];  cf.y = coefsHigh[6];  cf.z = coefsHigh[7];  j = 5;
        } else if (logy > KNOT_Y_HIGH[ 6] && logy <= KNOT_Y_HIGH[ 7]) {
            cf.x = coefsHigh[6];  cf.y = coefsHigh[7];  cf.z = coefsHigh[8];  j = 6;
        }

        const float3 tmp = mul(cf, M);

        float a = tmp[ 0];
        float b = tmp[ 1];
        float c = tmp[ 2];
        c = c - logy;

        const float d = sqrt(b * b - 4. * a * c);

        const float t = (2. * c) / (-d - b);

        logx = log10(midPoint.x) + (t + j) * KNOT_INC_HIGH;
    }
    else
    { //if (logy >= log10(maxPoint.y)) {
        logx = log10(maxPoint.x);
    }

    return pow(10, logx);
}

// Transformations from RGB to other color representations
float rgb_2_hue(float3 rgb)
{
    // Returns a geometric hue angle in degrees (0-360) based on RGB values.
    // For neutral colors, hue is undefined and the function will return a quiet NaN value.
    float hue;
    if (rgb[0] == rgb[1] && rgb[1] == rgb[2])
    {
        //hue = FLT_NAN; // RGB triplets where RGB are equal have an undefined hue
        hue = 0;
    }
    else
    {
        hue = (180. / PI) * atan2(sqrt(3.0)*(rgb[1] - rgb[2]), 2 * rgb[0] - rgb[1] - rgb[2]);
    }

    if (hue < 0.)
        hue = hue + 360;

    return clamp(hue, 0, 360);
}

float rgb_2_yc(float3 rgb)
{
    static const float ycRadiusWeight = 1.75;

    // Converts RGB to a luminance proxy, here called YC
    // YC is ~ Y + K * Chroma
    // Constant YC is a cone-shaped surface in RGB space, with the tip on the
    // neutral axis, towards white.
    // YC is normalized: RGB 1 1 1 maps to YC = 1
    //
    // ycRadiusWeight defaults to 1.75, although can be overridden in function
    // call to rgb_2_yc
    // ycRadiusWeight = 1 -> YC for pure cyan, magenta, yellow == YC for neutral
    // of same value
    // ycRadiusWeight = 2 -> YC for pure red, green, blue  == YC for  neutral of
    // same value.

    float r = rgb[0];
    float g = rgb[1];
    float b = rgb[2];

    float chroma = sqrt(b*(b-g)+g*(g-r)+r*(r-b));

    return (b + g + r + ycRadiusWeight * chroma) / 3.;
}

//
// Reference Rendering Transform (RRT)
//
//   Input is ACES
//   Output is OCES
//
float3 RRT(float3 aces)
{
    // "Glow" module constants
    static const float RRT_GLOW_GAIN = 0.05;
    static const float RRT_GLOW_MID = 0.08;

    float saturation = rgb_2_saturation(aces);
    float ycIn = rgb_2_yc(aces);
    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
    float addedGlow = 1 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
    aces *= addedGlow;

    // --- Red modifier --- //
    static const float RRT_RED_SCALE = 0.82;
    static const float RRT_RED_PIVOT = 0.03;
    static const float RRT_RED_HUE = 0;
    static const float RRT_RED_WIDTH = 135;

    float hue = rgb_2_hue(aces);
    float centeredHue = center_hue(hue, RRT_RED_HUE);
    float hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);

    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1. - RRT_RED_SCALE);

    // --- ACES to RGB rendering space --- //
    aces = clamp(aces, 0, 65535);  // avoids saturated negative colors from becoming positive in the matrix

    float3 rgbPre = mul(AP0_2_AP1_MAT, aces);

    rgbPre = clamp(rgbPre, 0, 65535);

    // --- Global desaturation --- //
    static const float RRT_SAT_FACTOR = 0.96;

    rgbPre = lerp(dot(rgbPre, AP1_RGB2Y), rgbPre, RRT_SAT_FACTOR);

    // --- Apply the tonescale independently in rendering-space RGB --- //
    float3 rgbPost;
    rgbPost[0] = segmented_spline_c5_fwd(rgbPre[0]);
    rgbPost[1] = segmented_spline_c5_fwd(rgbPre[1]);
    rgbPost[2] = segmented_spline_c5_fwd(rgbPre[2]);

    // AP1
    return rgbPost;
}

//
// Inverse Reference Rendering Transform (RRT)
//
//   Input is OCES
//   Output is ACES
//

float3 Inverse_RRT(float3 color)
{
    // "Glow" module constants
    static const float RRT_GLOW_GAIN = 0.05;
    static const float RRT_GLOW_MID = 0.08;

    float3 rgbPre = color; // AP1 space

    // --- Apply the tonescale independently in rendering-space RGB --- //
    float3 rgbPost;
    rgbPost[0] = segmented_spline_c5_rev(rgbPre[0]);
    rgbPost[1] = segmented_spline_c5_rev(rgbPre[1]);
    rgbPost[2] = segmented_spline_c5_rev(rgbPre[2]);

    // --- Global desaturation --- //
    // rgbPost = mul(rgbPost, invert_f33(RRT_SAT_MAT));
    static const float RRT_SAT_FACTOR = 0.96;
    rgbPost = lerp(dot(rgbPost, AP1_RGB2Y), rgbPost, rcp(RRT_SAT_FACTOR));

    rgbPost = clamp(rgbPost, 0., FLOAT_MAX);

    // --- RGB rendering space to ACES --- //
    float3 aces = mul(AP1_2_AP0_MAT, rgbPost);

    aces = clamp(aces, 0., FLOAT_MAX);

    // --- Red modifier --- //
    static const float RRT_RED_SCALE = 0.82;
    static const float RRT_RED_PIVOT = 0.03;
    static const float RRT_RED_HUE = 0;
    static const float RRT_RED_WIDTH = 135;

    float hue = rgb_2_hue(aces);
    float centeredHue = center_hue(hue, RRT_RED_HUE);
    float hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);

    float minChan;
    if (centeredHue < 0) {
        // min_f3(aces) = aces[1] (i.e. magenta-red)
        minChan = aces[1];
    } else { // min_f3(aces) = aces[2] (i.e. yellow-red)
        minChan = aces[2];
    }

    float a = hueWeight * (1. - RRT_RED_SCALE) - 1.;
    float b = aces[0] - hueWeight * (RRT_RED_PIVOT + minChan) * (1. - RRT_RED_SCALE);
    float c = hueWeight * RRT_RED_PIVOT * minChan * (1. - RRT_RED_SCALE);

    aces[0] = (-b - sqrt(b * b - 4. * a * c)) / (2. * a);

    // --- Glow module --- //
    float saturation = rgb_2_saturation(aces);
    float ycOut = rgb_2_yc(aces);
    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
    float reducedGlow = 1. + glow_inv(ycOut, RRT_GLOW_GAIN * s, RRT_GLOW_MID);

    aces = reducedGlow * aces;

    // Assign ACES RGB to output variables (ACES)
    return aces;
}



// Transformations between CIE XYZ tristimulus values and CIE x,y
// chromaticity coordinates
float3 XYZ_2_xyY(float3 XYZ)
{
    float3 xyY;
    float divisor = (XYZ[0] + XYZ[1] + XYZ[2]);
    if (divisor == 0.) divisor = 1e-10;
    xyY.x = XYZ.x / divisor;
    xyY.y = XYZ.y / divisor;
    xyY.z = XYZ.y;

    return xyY;
}

float3 xyY_2_XYZ(float3 xyY)
{
    float3 XYZ;
    XYZ.x = xyY.x * xyY.z / max(xyY.y, 1e-10);
    XYZ.y = xyY.z;
    XYZ.z = (1.0 - xyY.x - xyY.y) * xyY.z / max(xyY.y, 1e-10);

    return XYZ;
}


float3x3 ChromaticAdaptation(float2 src_xy, float2 dst_xy)
{
    // Von Kries chromatic adaptation

    // Bradford
    static const float3x3 ConeResponse = float3x3(
         0.8951,  0.2664, -0.1614,
        -0.7502,  1.7135,  0.0367,
         0.0389, -0.0685,  1.0296
    );
    static const float3x3 InvConeResponse = float3x3(
         0.9869929, -0.1470543,  0.1599627,
         0.4323053,  0.5183603,  0.0492912,
        -0.0085287,  0.0400428,  0.9684867
    );

    float3 src_XYZ = xyY_2_XYZ(float3(src_xy, 1));
    float3 dst_XYZ = xyY_2_XYZ(float3(dst_xy, 1));

    float3 src_coneResp = mul(ConeResponse, src_XYZ);
    float3 dst_coneResp = mul(ConeResponse, dst_XYZ);

    float3x3 VonKriesMat = float3x3(
        dst_coneResp[0] / src_coneResp[0], 0.0, 0.0,
        0.0, dst_coneResp[1] / src_coneResp[1], 0.0,
        0.0, 0.0, dst_coneResp[2] / src_coneResp[2]
    );

    return mul(InvConeResponse, mul(VonKriesMat, ConeResponse));
}

float Y_2_linCV(float Y, float Ymax, float Ymin)
{
  return (Y - Ymin) / (Ymax - Ymin);
}

float linCV_2_Y(float linCV, float Ymax, float Ymin)
{
  return linCV * (Ymax - Ymin) + Ymin;
}

// Gamma compensation factor
static const float DIM_SURROUND_GAMMA = 0.9811;

float3 darkSurround_to_dimSurround(float3 linearCV)
{
    float3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    float3 xyY = XYZ_2_xyY(XYZ);
    xyY.z = clamp(xyY.z, 0, 65535);
    xyY.z = pow(xyY.z, DIM_SURROUND_GAMMA);
    XYZ = xyY_2_XYZ(xyY);

    return mul(XYZ_2_AP1_MAT, XYZ);
}

float3 dimSurround_to_darkSurround(float3 linearCV)
{
  float3 XYZ = mul(linearCV, AP1_2_XYZ_MAT);

  float3 xyY = XYZ_2_xyY(XYZ);
  xyY.z = clamp(xyY.z, 0., 65535);
  xyY.z = pow(xyY.z, 1./DIM_SURROUND_GAMMA);
  XYZ = xyY_2_XYZ(xyY);

  return mul(XYZ, XYZ_2_AP1_MAT);
}

//
// Output Device Transform - RGB computer monitor (D60 simulation)
//

//
// Summary :
//  This transform is intended for mapping OCES onto a desktop computer monitor
//  typical of those used in motion picture visual effects production used to
//  simulate the image appearance produced by odt_p3d60. These monitors may
//  occasionally be referred to as "sRGB" displays, however, the monitor for
//  which this transform is designed does not exactly match the specifications
//  in IEC 61966-2-1:1999.
//
//  The assumed observer adapted white is D60, and the viewing environment is
//  that of a dim surround.
//
//  The monitor specified is intended to be more typical of those found in
//  visual effects production.
//
// Device Primaries :
//  Primaries are those specified in Rec. ITU-R BT.709
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.64      0.33
//              Green:        0.3       0.6
//              Blue:         0.15      0.06
//              White:        0.3217    0.329     100 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in
//  IEC 61966-2-1:1999.
//
// Signal Range:
//    This tranform outputs full range code values.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//   This ODT has a compensation for viewing environment variables more typical
//   of those associated with video mastering.
//

//
//  Epic edits:
//  - This ODT has been modified to target an observer adapted white of D65.
//  - The output of the function is linear output referred values. The
//      linear to sRGB transform should be applied after this function.
//

float3 ODT_sRGB_D65(float3 color)
{
    // AP1
    float3 rgbPre = color;

    // Apply the tonescale independently in rendering-space RGB
    float3 rgbPost;
    rgbPost.r = segmented_spline_c9_fwd(rgbPre.r);
    rgbPost.g = segmented_spline_c9_fwd(rgbPre.g);
    rgbPost.b = segmented_spline_c9_fwd(rgbPre.b);

    // Target white and black points for cinema system tonescale
    static const float CINEMA_WHITE = 48.0;
    static const float CINEMA_BLACK = 0.02; // CINEMA_WHITE / 2400.

    // Scale luminance to linear code value
    float3 linearCV;
    linearCV.r = Y_2_linCV(rgbPost[0], CINEMA_WHITE, CINEMA_BLACK);
    linearCV.g = Y_2_linCV(rgbPost[1], CINEMA_WHITE, CINEMA_BLACK);
    linearCV.b = Y_2_linCV(rgbPost[2], CINEMA_WHITE, CINEMA_BLACK);

    // Apply gamma adjustment to compensate for dim surround
    linearCV = darkSurround_to_dimSurround(linearCV);

    // Apply desaturation to compensate for luminance difference
    static const float ODT_SAT_FACTOR = 0.93;
    linearCV = lerp(dot(linearCV, AP1_RGB2Y), linearCV, ODT_SAT_FACTOR);

    // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

    // Apply CAT from ACES white point to assumed observer adapted white point
    /*
    static const float3x3 D60_2_D65_CAT = float3x3(
         0.987224,   -0.00611327, 0.0159533,
        -0.00759836,  1.00186,    0.00533002,
         0.00307257, -0.00509595, 1.08168
    );
    */
    XYZ = mul(D60_2_D65_CAT, XYZ);

    // CIE XYZ to display primaries
    linearCV = mul(XYZ_2_sRGB_MAT, XYZ);

    // Handle out-of-gamut values
    linearCV = saturate(linearCV);

    return linearCV;
}

//
// Inverse Output Device Transform - RGB computer monitor (D65 simulation)
//

//
//  Epic edits:
//  - This Inverse ODT has been modified to accept an observer adapted white of D65.
//  - The input to the function is linear output referred values. The
//      sRGB to linear transform should be applied before this function.
//

float3 Inverse_ODT_sRGB_D65(float3 linearCV)
{
    // Convert from display primary encoding
    // Display primaries to CIE XYZ
    float3 XYZ = mul(sRGB_2_XYZ_MAT, linearCV);

    // CIE XYZ to rendering space RGB
    linearCV = mul(XYZ_2_AP1_MAT, XYZ);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mul(D65_2_D60_CAT, XYZ);

    // Undo desaturation to compensate for luminance difference
    //linearCV = mul(linearCV, invert_f33(ODT_SAT_MAT));
    static const float ODT_SAT_FACTOR = 0.93;
    linearCV = lerp(dot(linearCV, AP1_RGB2Y), linearCV, rcp(ODT_SAT_FACTOR));

    // Undo gamma adjustment to compensate for dim surround
    linearCV = dimSurround_to_darkSurround(linearCV);

    // Undo scaling done for D60 simulation
    static const float SCALE = 0.955;
    linearCV = linearCV * rcp(SCALE);

    // Target white and black points for cinema system tonescale
    static const float CINEMA_WHITE = 48.0;
    static const float CINEMA_BLACK = 0.02; // CINEMA_WHITE / 2400.

    // Scale linear code value to luminance
    float3 rgbPre;
    rgbPre.r = linCV_2_Y(linearCV[0], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre.g = linCV_2_Y(linearCV[1], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre.b = linCV_2_Y(linearCV[2], CINEMA_WHITE, CINEMA_BLACK);

    // Apply the tonescale independently in rendering-space RGB
    float3 rgbPost;
    rgbPost.r = segmented_spline_c9_rev(rgbPre.r);
    rgbPost.g = segmented_spline_c9_rev(rgbPre.g);
    rgbPost.b = segmented_spline_c9_rev(rgbPre.b);

    // AP1
    return rgbPost;
}

float3 InverseACESFull(float3 c)
{
    c = Inverse_ODT_sRGB_D65(c);
    c = Inverse_RRT(c);

    return c;
}

float3 ApplyACESFull(float3 c)
{
    c = RRT(c);
    c = ODT_sRGB_D65(c);

    return c;
}

float3 ACEScgToACEScct(float3 c)
{
    return c < 0.0078125 ? (10.5402377 * c + 0.0729055) : ((log2(c) + 9.72) / 17.52);
}

float3 ACEScctToACEScg(float3 c)
{
    return c > 0.1552511 ? exp2(c * 17.52 - 9.72) : ((c - 0.0729055) / 10.5402377);
}

float3 ACEScgToACEScc(float3 c)
{
    return c <= 0 ? -0.3584475 : c < 0.0000305 ? ((log2(0.0000153 + c * 0.5) + 9.72) / 17.52) : (log2(c) + 9.72) / 17.52;
}

float3 ACESccToACEScg(float3 c)
{
    return c < -0.3013699 ? (exp2(c * 17.52 - 9.72) * 2.0 - 0.0000306) : c < 1.4680365 ? exp2(c * 17.52 - 9.72) : FLOAT_MAX;
}

float ACESToLumi(float3 c)
{
    return dot(c, float3(0.272229, 0.674082, 0.0536895));
}

float3 RGBToACEScg(float3 c)
{
    static const float3x3 BT709_2_AP1 = float3x3(0.6130973, 0.3395229, 0.0473793, 0.0701942, 0.9163556, 0.0134526, 0.0206156, 0.1095698, 0.8698151);

    return mul(BT709_2_AP1, c);
}

float3 ACEScgToRGB(float3 c)
{
    static const float3x3 AP1_2_BT709 = float3x3(1.70505, -0.621791, -0.0832584, -0.130257, 1.1408, -0.0105485, -0.0240033, -0.128969, 1.15297);

    return mul(AP1_2_BT709, c);
}

float3 ApplyACESFitted(float3 c)
{
    static const float3x3 AP1_2_AP0 = float3x3(0.6954522, 0.1406787, 0.1638690, 0.0447946, 0.8596711, 0.0955343, -0.0055259, 0.0040252, 1.0015007);
    c = mul(AP1_2_AP0, c);

    // glow module
    float saturation = rgb_2_saturation(c);
    float s = sigmoid_shaper(saturation * 5.0 - 2.0);
    c *= 1.0 + glow_fwd(rgb_2_yc(c), 0.05 * s, 0.08);

    // red modifier
    float centered_hue = rgb_2_hue(c);
    float hue_weight = smoothstep(0.0, 1.0, 1.0 - abs(centered_hue / 67.5)); hue_weight *= hue_weight;
    c.r += hue_weight * saturation * (0.03 - c.r) * 0.18;

    // RRT desaturation
    static const float3x3 AP0_2_AP1_2_RRT_SAT = float3x3(1.40427, -0.200087, -0.204184, -0.0626024, 1.15614, -0.0935414, 0.0188727, 0.0211722, 0.959956);
    c = max(0.0, c);
    c = mul(AP0_2_AP1_2_RRT_SAT, c);

    // Red is Hill's, Blue is color-science's curve https://www.desmos.com/calculator/to1kpt4pwc

    // Stephen Hill's curve
    c = (c * (c + 0.0245786) - 0.000090537) * RCP(c * (0.983729 * c + 0.4329510) + 0.238081);
    // color-science curve
    /* c = (c * (278.5085 * c + 10.7772)) * RCP(c * (293.6045 * c + 88.7122) + 80.6889); */

    static const float3x3 ODT_SAT_2_D60XYZ_2_D65XYZ_2_BT709 = float3x3(1.60475, -0.53108, -0.07367, -0.10208,  1.10813, -0.00605, -0.00327, -0.07276,  1.07602);
    c = mul(ODT_SAT_2_D60XYZ_2_D65XYZ_2_BT709, c);

    return c;
}

float3 ApplyACESNarkowicz(float3 x)
{
    static const float a = 2.51;
    static const float b = 0.03;
    static const float c = 2.43;
    static const float d = 0.59;
    static const float e = 0.14;

    return (x*(a*x+b)) * RCP(x*(c*x+d)+e);
}

float3 InverseACESNarkowicz(float3 x)
{
    static const float a = 2.51;
    static const float b = 0.03;
    static const float c = 2.43;
    static const float d = 0.59;
    static const float e = 0.14;

    return (sqrt(2.0*(2.0*a*e - b*d)*x + b*b - (4.0*c*e - d*d) * x*x) + d*x - b) * RCP(2.0*(a - c*x));
}
