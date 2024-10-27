exports.ROSTER_URL =
  "https://classes.cornell.edu/api/2.0/search/classes.json?roster=SP25";

// Success and Error JSON
exports.errorResponse = function (msg, code, res) {
  return res.status(code).json({ status: "error", result: msg });
};

exports.successResponse = function (data, code, res) {
  return res.status(code).json({ status: "success", result: data });
};
