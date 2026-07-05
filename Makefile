#
# Copyright (C) 2025 OpenWrt
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# 软件包基础信息
PKG_NAME:=node-red
PKG_VERSION:=5.0.1
PKG_RELEASE:=1

# 上游官方源码地址（后续同步工作流自动更新版本号）
PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/node-red/node-red/archive/v$(PKG_VERSION).tar.gz
PKG_HASH:=skip

# 依赖：nodejs运行环境
PKG_BUILD_DEPENDS:=node/host nodejs
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/node.mk

# 软件包描述
define Package/node-red
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Node.js
  TITLE:=Low-code programming for event-driven applications
  DEPENDS:=+nodejs +npm
  URL:=https://nodered.org
endef

define Package/node-red/description
 Node-RED is a programming tool for wiring together hardware devices, APIs and online services.
endef

# 编译前打自定义补丁（适配OpenWrt路径）
define Build/Prepare
	$(call Build/Prepare/Default)
	# 应用仓库内patches下所有补丁
	if [ -d $(PKG_BUILD_DIR)/../patches ]; then \
		for p in $(PKG_BUILD_DIR)/../patches/*.patch; do \
			patch -d $(PKG_BUILD_DIR) -p1 < $$p; \
		done; \
	fi
endef

# NPM安装逻辑，预装核心节点
define Build/Compile
	$(NPM) install --prefix $(PKG_BUILD_DIR)
	$(NPM) pack --prefix $(PKG_BUILD_DIR)
endef

# 安装文件、开机脚本到固件
define Package/node-red/install
	$(INSTALL_DIR) $(1)/usr/lib/node_modules/node-red
	$(CP) $(PKG_BUILD_DIR)/* $(1)/usr/lib/node_modules/node-red/
	
	# 安装启动脚本
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/node-red $(1)/etc/init.d/node-red
	
	# 创建数据持久化目录
	$(INSTALL_DIR) $(1)/root/.node-red
endef

$(eval $(call BuildPackage,node-red))
