shader_type canvas_item;
/*
 * This shader code was created and published by SpeedyVelcro in 2026.
 * 
 * This is free and unencumbered software released into the public domain.
 * 
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 * 
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 * 
 * For more information, please refer to <https://unlicense.org/>
 */

/**
 * Perceived luminance of the red channel. This determines how much the red
 * channel contributes to the brightness of each pixel in the final image. The
 * default value of 0.2126 is taken from Recommendation ITU-R BT.709-6. See
 * https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
 * 
 * For better contrast, you may prefer to use 0.299, which is taken from
 * Techniques For Accessibility Evaluation And Repair Tools, W3C Working Draft,
 * 26 April 2000. See https://www.w3.org/TR/2000/WD-AERT-20000426
 */
uniform float red_luminance = 0.2126;
/**
 * Perceived luminance of the green channel. This determines how much the green
 * channel contributes to the brightness of each pixel in the final image. The
 * default value of 0.0722 is taken from Recommendation ITU-R BT.709-6. See
 * https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
 * 
 * For better contrast, you may prefer to use 0.587, which is taken from
 * Techniques For Accessibility Evaluation And Repair Tools, W3C Working Draft,
 * 26 April 2000. See https://www.w3.org/TR/2000/WD-AERT-20000426
 */
uniform float green_luminance = 0.7152;
/**
 * Perceived luminance of the blue channel. This determines how much the blue
 * channel contributes to the brightness of each pixel in the final image. The
 * default value of 0.0722 is taken from Recommendation ITU-R BT.709-6. See
 * https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.709-6-201506-I!!PDF-E.pdf
 * 
 * For better contrast, you may prefer to use 0.114, which is taken from
 * Techniques For Accessibility Evaluation And Repair Tools, W3C Working Draft,
 * 26 April 2000. See https://www.w3.org/TR/2000/WD-AERT-20000426
 */
uniform float blue_luminance = 0.0722;

void fragment() {
	COLOR.rgb = vec3(
			red_luminance * COLOR.r
			+ green_luminance * COLOR.g
			+ blue_luminance * COLOR.b);
}
