# Index

[Introduction](#introduction)
[Layout](#layout)
[Usage](#usage)

<br/>
<br/>

# Introduction

An implementation of the AES-128 encryption algorithm in VHDL.
The implementation is confirmed using the FIPS 197 and The Advanced Encryption Standard Algorithm Validation Suite (AESAVS) papers.

<br/>
<br/>

# Layout

**aes_128_pkg:**
- Contains the types, constants, and functions defined by the FIPS 197 AES-128 standard.

**aes_128_encrypt:**
- Contains the encrypt entity and behavioral architecture.
- Dataflow and structural models have yet to be completed.
- Asynchronous reset is available.

**test-bench/aes_128_encrypt_tb:**
- Contains test cases for the encryption portion of the AES-128 algorithm and shared functions.
- Contains test cases for the encryption behavioral architecture including ECB and CBC mode.

**aes_128_decrypt:**
- Contains the decrypt entity and behavioral architecture.
- Dataflow and structural models have yet to be completed.
- Asynchronous reset is available.

**test-bench/aes_128_decrypt_tb:**
- Contains test cases for the decryption portion of the AES-128 algorithm.
- Contains test cases for the decryption behavioral architecture including ECB and CBC mode.

<br/>
<br/>

# Usage

Each step is a clock cycle.

**Encryption:**
1. Set the START signal to logic high.
1. Set the KEY_LOAD signal to logic high.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Set the IV_LOAD signal to logic high.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Set the STREAM signal to logic high.
1. Set **either** ECB_MODE or CBC_MODE to logic high.
1. Set the DB_LOAD signal to logic high.
1. Load 32 bits of plain text.
1. Load 32 bits of plain text.
1. Load 32 bits of plain text.
1. Load 32 bits of plain text.
1. Encryption will occur in a single clock cycle.
1. DONE is set to logic high and the first 32 bits of cipher text are available on DATA_OUT.
1. DATA_OUT contains 32 bits of the cipher text.
1. DATA_OUT contains 32 bits of the cipher text.
1. DATA_OUT contains 32 bits of the cipher text.
1. GOTO 14.

**Decryption:**
1. Set the START signal to logic high.
1. Set the KEY_LOAD signal to logic high.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Load 32 bits of the key.
1. Set the IV_LOAD signal to logic high.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Load 32 bits of the iv.
1. Set the STREAM signal to logic high.
1. Set **either** ECB_MODE or CBC_MODE to logic high.
1. Set the DB_LOAD signal to logic high.
1. Load 32 bits of cipher text.
1. Load 32 bits of cipher text.
1. Load 32 bits of cipher text.
1. Load 32 bits of cipher text.
1. Encryption will occur in a single clock cycle.
1. DONE is set to logic high and the first 32 bits of plain text are available on DATA_OUT.
1. DATA_OUT contains 32 bits of the plain text.
1. DATA_OUT contains 32 bits of the plain text.
1. DATA_OUT contains 32 bits of the plain text.
1. GOTO 14.

<br/>
<br/>
