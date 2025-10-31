#include "coverage.h"
#include "greeting/greeting.h"
#include <gtest/gtest.h>
#include <sstream>
#include <iostream>

// Helper class to capture cout output
class CoutCapture {
public:
    CoutCapture() {
        old_cout_buffer = std::cout.rdbuf();
        std::cout.rdbuf(captured_output.rdbuf());
    }
    
    ~CoutCapture() {
        std::cout.rdbuf(old_cout_buffer);
    }
    
    std::string getOutput() {
        return captured_output.str();
    }

private:
    std::streambuf* old_cout_buffer;
    std::ostringstream captured_output;
};

// =============================================================================
// MAIN FUNCTION TESTS
// =============================================================================

// Test fixture class for main functionality
class CoverageTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup code if needed
    }
    
    void TearDown() override {
        // Cleanup code if needed
    }
};

// Test main function with no arguments (argc = 1) - should greet "World"
TEST_F(CoverageTest, MainWithNoArguments) {
    CoutCapture capture;
    const char* argv[] = {"./hello"};
    coverage::runMain(1, const_cast<char**>(argv));
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, World!\n");
}

// Test main function with one argument - should greet that argument
TEST_F(CoverageTest, MainWithOneArgument) {
    CoutCapture capture;
    const char* argv[] = {"./hello", "Alice"};
    coverage::runMain(2, const_cast<char**>(argv));
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, Alice!\n");
}

// Test main function with "Uwe" argument - should trigger special greeting
TEST_F(CoverageTest, MainWithUweArgument) {
    CoutCapture capture;
    const char* argv[] = {"./hello", "Uwe"};
    coverage::runMain(2, const_cast<char**>(argv));
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello there, Uwe! Great to see you!\n");
}

// Test main function with multiple arguments - should only use the first one
TEST_F(CoverageTest, MainWithMultipleArguments) {
    CoutCapture capture;
    const char* argv[] = {"./hello", "Bob", "Charlie", "David"};
    coverage::runMain(4, const_cast<char**>(argv));
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, Bob!\n");
}

// Test edge case: argc = 0 (unusual but possible)
TEST_F(CoverageTest, MainWithZeroArgc) {
    CoutCapture capture;
    const char* argv[] = {};
    coverage::runMain(0, const_cast<char**>(argv));
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, World!\n");
}

// =============================================================================
// GREETING LIBRARY TESTS
// =============================================================================

// Test fixture class for greeting library
class GreetingTest : public ::testing::Test {
protected:
    void SetUp() override {
        // Setup code if needed
    }
    
    void TearDown() override {
        // Cleanup code if needed
    }
};

// Test case for greeting "Uwe" - should trigger special greeting
TEST_F(GreetingTest, GreetingForUwe) {
    CoutCapture capture;
    greeting::printGreeting("Uwe");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello there, Uwe! Great to see you!\n");
}

// Test case for greeting any other name - should trigger regular greeting
TEST_F(GreetingTest, GreetingForRegularName) {
    CoutCapture capture;
    greeting::printGreeting("Alice");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, Alice!\n");
}

// Test case for empty string
TEST_F(GreetingTest, GreetingForEmptyString) {
    CoutCapture capture;
    greeting::printGreeting("");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, !\n");
}

// Test case for "World" - typical default case
TEST_F(GreetingTest, GreetingForWorld) {
    CoutCapture capture;
    greeting::printGreeting("World");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, World!\n");
}

// Test case for case sensitivity - "uwe" (lowercase) should not trigger special greeting
TEST_F(GreetingTest, GreetingForLowercaseUwe) {
    CoutCapture capture;
    greeting::printGreeting("uwe");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, uwe!\n");
}

// Test case for case sensitivity - "UWE" (uppercase) should not trigger special greeting
TEST_F(GreetingTest, GreetingForUppercaseUWE) {
    CoutCapture capture;
    greeting::printGreeting("UWE");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, UWE!\n");
}

// Test case for string containing "Uwe" but not exactly "Uwe"
TEST_F(GreetingTest, GreetingForStringContainingUwe) {
    CoutCapture capture;
    greeting::printGreeting("Uwe Müller");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, Uwe Müller!\n");
}

// Test case for numeric input
TEST_F(GreetingTest, GreetingForNumericInput) {
    CoutCapture capture;
    greeting::printGreeting("123");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, 123!\n");
}

// Test case for special characters
TEST_F(GreetingTest, GreetingForSpecialCharacters) {
    CoutCapture capture;
    greeting::printGreeting("@#$%");
    std::string output = capture.getOutput();
    
    EXPECT_EQ(output, "Hello, @#$%!\n");
}
