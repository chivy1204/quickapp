using System;
using Xunit;

namespace QuickApp.Tests
{
    public class UnitTest1
    {
        [Fact]
        public void Test1()
        {
            Assert.True(true);
        }
        [Fact]
        public void Test2()
        {
            Assert.True(true);
        }
        [Fact]
        public void Test3()
        {
            Assert.False(false);
        }
        [Fact]
        public void Test4()
        {
            Assert.True(true);
        }
        [Fact]
        public void Test5()
        {
            Assert.True(true);
        }
        [Fact]
        public void Test6()
        {
            Assert.False(true);
        }
    }
}
