package com.quanqinle.myworld.controller;

import com.quanqinle.myworld.entity.po.TaxRate;
import com.quanqinle.myworld.entity.vo.TaxPlan;
import com.quanqinle.myworld.service.TaxRateService;
import com.quanqinle.myworld.util.TaxPlanUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;

/**
 * @author quanqinle
 */
@Controller
@RequestMapping("/tax")
public class TaxRateController {
	Log log = LogFactory.getLog(TaxRateController.class);

	@Autowired
	TaxRateService taxRateService;

	@GetMapping("/list.html")
	public String allRate(Model model) {
		model.addAttribute("ratelist", taxRateService.getAllTaxRate());
		//properties中设置了缺省.ftl，所以跳转ratelist.ftl
		return "/pages/ratelist";
	}

	/**
	 * 个税计算页面
	 *
	 * @return
	 */
	@GetMapping(value = {"/calc", "/plan"})
	public String calcTaxRate(Model model) {
		// FIXME 据说：“在渲染页面之前，我们通过model.addAttribute("helloMessage", new HelloMessage());告诉页面绑定到一个空的HelloMessage对象，这样sayHello.html页面初始时就会显示一个空白的表单。”
		// 实测无效，还是显示上次提交的结果
		model.addAttribute("taxrate", new TaxRate());
		return "/pages/ratecalc";
	}

	@GetMapping("/list.json")
	@ResponseBody
	public List<TaxRate> allRate() {
		return taxRateService.getAllTaxRate();
	}

	/**
	 * 提交个税查询
	 *
	 * @param income
	 * @return
	 */
	@GetMapping("/calc_tax")
	@ResponseBody
	public HashMap<String, Object> calcResult(@RequestParam(name = "income") double income) {
		double taxableSalary = TaxPlanUtils.calcTaxableSalary(income);
		double tax = TaxPlanUtils.calcTaxes(taxableSalary);
		TaxRate taxRate = TaxPlanUtils.getTaxRate(taxableSalary);

		HashMap<String, Object> result = new HashMap<>(16);
		result.put("taxes", tax);
		result.put("taxrate", taxRate);

		return result;
	}

	@PostMapping("/opt_plan")
	@ResponseBody
	public HashMap<String, Object> planSubmit(Double estimatedAnnualSalary, Double alreadyPaidSalary, Integer remainingMonths) {
		TaxPlan taxplan = TaxPlanUtils.calcBestTaxPlanQuickly(estimatedAnnualSalary, alreadyPaidSalary, remainingMonths);
		HashMap<String, Object> result = new HashMap<>(16);
		result.put("taxplan", taxplan);

		return result;
	}

	@GetMapping("/income/{income}")
	@ResponseBody
	public TaxRate getRateByIncome(@PathVariable double income) {
		double taxableSalary = TaxPlanUtils.calcTaxableSalary(income);
		return taxRateService.getTaxRateByRange(taxableSalary);
	}

	@GetMapping("/env")
	@ResponseBody
	public String getEnv(@Value("${user.dir:false}") String userDir) {
		return "user.dir = " + userDir;
	}
}
