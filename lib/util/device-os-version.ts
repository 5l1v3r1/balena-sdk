import bSemver = require('balena-semver');
import * as BalenaSdk from '../../typings/balena-sdk';
import { isProvisioned } from './device';

export const normalizeDeviceOsVersion = (device: BalenaSdk.Device) => {
	if (
		device.os_version != null &&
		device.os_version.length === 0 &&
		isProvisioned(device)
	) {
		device.os_version = 'Resin OS 1.0.0-pre';
	}
};

export const getDeviceOsSemverWithVariant = ({
	os_version,
	os_variant,
}: Pick<BalenaSdk.Device, 'os_version' | 'os_variant'>) => {
	if (!os_version) {
		return null;
	}

	const versionInfo = bSemver.parse(os_version);
	if (!versionInfo) {
		return null;
	}

	let { version } = versionInfo;
	const build = versionInfo.build.slice();
	if (
		os_variant &&
		![...build, ...versionInfo.prerelease].includes(os_variant)
	) {
		build.push(os_variant);
	}

	if (build.length > 0) {
		version = `${version}+${build.join('.')}`;
	}

	return version;
};
