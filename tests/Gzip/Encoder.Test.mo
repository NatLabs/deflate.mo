import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Blob "mo:base/Blob";

import ActorSpec "../utils/ActorSpec";
import Gzip "../../src/Gzip";
import GzipEncoder "../../src/Gzip/Encoder";
import Example "../data-files/dickens5";

let {
    assertTrue;
    assertFalse;
    assertAllTrue;
    describe;
    it;
    skip;
    pending;
    run;
} = ActorSpec;

let success = run([
    describe(
        " Gzip Encoder",
        [
            it(
                "No compression",
                do {
                    let gzip_encoder = Gzip.EncoderBuilder().noCompression().build();
                    let input = Text.encodeUtf8("Hello World");
                    let bytes = Blob.toArray(input);

                    gzip_encoder.encode(bytes);
                    let output = gzip_encoder.finish();

                    assertTrue(
                        output == [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0x01, 0x0B, 0x00, 0xF4, 0xFF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00],
                    );
                },
            ),
            describe("Compression: Fixed Huffman codes", [
                it(
                    "Compress \"Hello world\" (no back references)",
                    do {
                        let gzip_encoder = Gzip.EncoderBuilder().build();
                        let input = Text.encodeUtf8("Hello World");
                        let bytes = Blob.toArray(input);

                        gzip_encoder.encode(bytes);
                        let output = gzip_encoder.finish();

                        assertTrue( output == [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0xF3, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0x08, 0xCF, 0x2F, 0xCA, 0x49, 0x01, 0x00, 0x56, 0xB1, 0x17, 0x4A, 0x0B, 0x00, 0x00, 0x00] );
                    },
                ),
                it(
                    "Compress short text",
                    do {
                        let gzip_encoder = Gzip.EncoderBuilder().build();
                        let text = "Literature is full of repetition. Literary writers constantly use the literary device of repeated words. I think the only type of repetition which is bad is sloppy repetition. Repetition which is unintentional, which sounds awkward.";
                        let input = Text.encodeUtf8(text);
                        let bytes = Blob.toArray(input);

                        gzip_encoder.encode(bytes);
                        let output = gzip_encoder.finish();
                        Debug.print("short text example: " # debug_show (text.size()) # " -> " # debug_show output.size() # " bytes");
                        assertTrue( output == [0x1F, 0x8B, 0x08, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x00, 0x03, 0xF3, 0xC9, 0x2C, 0x49, 0x2D, 0x4A, 0x2C, 0x29, 0x2D, 0x4A, 0x55, 0xC8, 0x2C, 0x56, 0x48, 0x2B, 0xCD, 0xC9, 0x51, 0xC8, 0x4F, 0x53, 0x28, 0x4A, 0x2D, 0x48, 0x2D, 0xC9, 0x2C, 0xC9, 0xCC, 0xCF, 0xD3, 0x53, 0x80, 0xA8, 0x28, 0xAA, 0x54, 0x28, 0x2F, 0x02, 0xB1, 0x8A, 0x15, 0x92, 0xF3, 0xF3, 0x8A, 0x4B, 0x12, 0xF3, 0x4A, 0x72, 0x2A, 0x15, 0x4A, 0x8B, 0x53, 0x15, 0x4A, 0x32, 0x52, 0x15, 0x72, 0x40, 0x32, 0x20, 0x35, 0x29, 0xA9, 0x65, 0x99, 0xC9, 0xA9, 0x30, 0x23, 0x12, 0x4B, 0x52, 0x53, 0x14, 0xCA, 0xF3, 0x8B, 0x52, 0x8A, 0xF5, 0x14, 0x3C, 0x81, 0x0A, 0x33, 0xF3, 0xB2, 0x81, 0x24, 0x50, 0x3A, 0x0F, 0xA8, 0xB7, 0xA4, 0xB2, 0x00, 0xC8, 0x82, 0x28, 0x84, 0xD8, 0xA5, 0x50, 0x9E, 0x91, 0x99, 0x9C, 0x01, 0x72, 0x47, 0x52, 0x62, 0x0A, 0x88, 0x2A, 0xCE, 0xC9, 0x2F, 0x28, 0xA8, 0x44, 0x52, 0xA1, 0xA7, 0x10, 0x04, 0x67, 0x23, 0x54, 0x97, 0xE6, 0x65, 0xE6, 0x95, 0xA4, 0xE6, 0x81, 0x04, 0x13, 0x73, 0x74, 0xA0, 0xE2, 0xC5, 0xF9, 0xA5, 0x79, 0x29, 0xC5, 0x0A, 0x89, 0xE5, 0xD9, 0xE5, 0x89, 0x45, 0x29, 0x7A, 0x00, 0x7E, 0x9C, 0xB5, 0x21, 0xE8, 0x00, 0x00, 0x00] );
                    },
                ),
                it("Compression of large files with Fixed Huffman codes", do{
                    let gzip_encoder = Gzip.EncoderBuilder().build();
                    let input = Text.encodeUtf8(Example.text);
                    let bytes = Blob.toArray(input);

                    gzip_encoder.encode(bytes);
                    let output = gzip_encoder.finish();
                    Debug.print("Example: " # debug_show (Example.text.size()) # " -> " # debug_show output.size() # " bytes");

                    assertTrue( 
                        output == Blob.toArray(Example.fixed_code_compression)    
                    );
                })
            ]),

            describe("Compression: Dynamic Huffman codes", [
                it("Compress short text", do {
                    
                    let gzip_encoder = GzipEncoder
                        .EncoderBuilder()
                        .dynamicHuffman()
                        .build();

                    let text = "Literature is full of repetition. Literary writers constantly use the literary device of repeated words. I think the only type of repetition which is bad is sloppy repetition. Repetition which is unintentional, which sounds awkward.";
                    let input = Text.encodeUtf8(text);
                    let bytes = Blob.toArray(input);

                    gzip_encoder.encode(bytes);
                    let output = gzip_encoder.finish();
                    Debug.print("short text example: " # debug_show (text.size()) # " -> " # debug_show output.size() # " bytes");
                    Debug.print(debug_show output);
                    true
                })
            ])
        ],
    )
]);

if (success == false) {
    Debug.trap("\1b[46;41mTests failed\1b[0m");
} else {
    Debug.print("\1b[23;42;3m Success!\1b[0m");
};
