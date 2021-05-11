using Microsoft.AspNetCore.Mvc;
using System.Text.Encodings.Web;
namespace QuickApp.Controllers
{
    public class HomeController
    {
        // 
        // GET: /HelloWorld/

        public string Index()
        {
            return "This is my default action...";
        }

        // 
        // GET: /HelloWorld/Welcome/ 

        public string Welcome()
        {
            return "This is the Welcome action method...";
        }
    }
}