
const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  const authorization = req.headers.authorization;

  if (!authorization || !authorization.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required. Please log in again.',
    });
  }

  const token = authorization.slice(7);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    if (!decoded.userId || !decoded.role) {
      return res.status(401).json({
        success: false,
        message: 'Invalid authentication token.',
      });
    }

    req.user = {
      userId: decoded.userId,
      role: decoded.role,
    };

    return next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Your session is invalid or expired. Please log in again.',
    });
  }
}

module.exports = authMiddleware;
