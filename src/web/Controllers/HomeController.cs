using System.Web.Mvc;

namespace nuget_mvc3_site.Controllers
{
    public class HomeController : Controller
    {
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }
    }
}
